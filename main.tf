data "google_projects" "my-org-projects" {
  filter = "lifecycleState:ACTIVE"
}

resource "google_folder" "my_host_folder" {
  display_name = var.host_folder_name
  parent       = "organizations/${var.organization_id}"

}

resource "google_project" "my_host_project" {
  name       = var.host_project_id == "" ? "uptycs-${substr(md5(var.organization_id), -7, -1)}" : var.host_project_id
  project_id = var.host_project_id == "" ? "uptycs-${substr(md5(var.organization_id), -7, -1)}" : var.host_project_id
  folder_id  = google_folder.my_host_folder.name

  labels = var.host_project_tags
}

resource "google_service_account" "sa_for_hostproject" {
  project      = google_project.my_host_project.project_id
  account_id   = var.service_account_name
  display_name = var.service_account_name
  description  = "Service Account for Intergration"
}

resource "google_project_iam_member" "bind_security_viewer" {
  role    = "roles/iam.securityReviewer"
  project = google_project.my_host_project.project_id
  member  = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_project_iam_member" "bind_resourceViewer" {
  role    = "roles/bigquery.resourceViewer"
  project = google_project.my_host_project.project_id
  member  = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_project_iam_member" "bind_pubsub_subscriber" {
  role    = "roles/pubsub.subscriber"
  project = google_project.my_host_project.project_id
  member  = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_project_iam_member" "bind_viewer" {
  role    = "roles/viewer"
  project = google_project.my_host_project.project_id
  member  = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_project_iam_member" "bind_viewer_SA_to_filter_projects" {
  for_each   = var.integration_projects == "" ? toset( data.google_projects.my-org-projects.projects[*].project_id) : toset( split(",",var.integration_projects))
  project    = each.key
  role       = "roles/viewer"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_project_iam_member" "bind_resourceViewer_SA_to_filter_projects" {
  for_each   = var.integration_projects == "" ? toset( data.google_projects.my-org-projects.projects[*].project_id) : toset( split(",",var.integration_projects))
  project    = each.key
  role       = "roles/bigquery.resourceViewer"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"

}

resource "google_project_iam_member" "bind_pubsub_SA_to_filter_projects" {
  for_each   = var.integration_projects == "" ? toset( data.google_projects.my-org-projects.projects[*].project_id) : toset( split(",",var.integration_projects))
  project    = each.key
  role       = "roles/pubsub.subscriber"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_project_iam_member" "bind_securityReviewer_SA_to_filter_projects" {
  for_each   = var.integration_projects == "" ? toset( data.google_projects.my-org-projects.projects[*].project_id) : toset( split(",",var.integration_projects))
  project    = each.key
  role       = "roles/iam.securityReviewer"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_iam_workload_identity_pool" "create_wip" {
  provider                  = google-beta
  project                   = google_project.my_host_project.project_id
  workload_identity_pool_id = var.gcp_workload_identity
  display_name              = var.gcp_workload_identity
  description               = "Workload Identity Pool to allow Uptycs integration via AWS federation"
  disabled                  = false

  timeouts {
    create = "10m"
  }
}

resource "google_iam_workload_identity_pool_provider" "add_provider" {
  provider                           = google-beta
  project                            = google_project.my_host_project.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.create_wip.workload_identity_pool_id
  workload_identity_pool_provider_id = var.gcp_wip_provider_id
  aws {
    account_id                       = var.host_aws_account_id
  }
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.sa_for_hostproject.name

  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/projects/${google_project.my_host_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.create_wip.workload_identity_pool_id}/attribute.aws_role/arn:aws:sts::${var.host_aws_account_id}:assumed-role/${var.host_aws_instance_role}"
  ]
  depends_on = [google_iam_workload_identity_pool.create_wip]
}

resource "null_resource" "cred_config_json" {
  provisioner "local-exec" {
    command     = "gcloud iam workload-identity-pools create-cred-config projects/${google_project.my_host_project.number}/locations/global/workloadIdentityPools/${var.gcp_workload_identity}/providers/${var.gcp_wip_provider_id} --service-account=${google_service_account.sa_for_hostproject.email} --output-file=credentials.json --aws"
    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [google_service_account_iam_binding.workload_identity_binding]
}


resource "null_resource" "project_list" {
  provisioner "local-exec" {
    command     = var.integration_projects == "" ? "gcloud projects list --filter 'lifecycleState: ACTIVE AND projectId != ${google_project.my_host_project.project_id}' --format=\"json\" | jq -c > project_list.json" : "eval $(echo ${var.integration_projects} | sed -e 's/^/gcloud projects list --filter=\"project_id:/g' |sed -e 's/,/ OR project_id:/g' | sed -e 's/$/\" --format=\"json\" | jq -c/g') > project_list.json"
    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [data.google_projects.my-org-projects]
}
