data "google_projects" "my-org-projects" {
  filter = "lifecycleState:ACTIVE"
}

resource "google_folder" "my_host_folder" {
  display_name = var.integration_name
  parent       = "organizations/${var.organization_id}"
}

resource "google_project" "my_host_project" {
  name       = var.integration_name
  project_id = var.integration_name
  folder_id  = google_folder.my_host_folder.name

  labels = var.host_project_tags
}

resource "google_project_service" "bigquery_service" {
   project = google_project.my_host_project.project_id
   service = "bigquery.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "bigquerymigration_service" {
   project = google_project.my_host_project.project_id
   service = "bigquerymigration.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "bigquerystorage_service" {
   project = google_project.my_host_project.project_id
   service = "bigquerystorage.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "cloudapis_service" {
   project = google_project.my_host_project.project_id
   service = "cloudapis.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "clouddebugger_service" {
   project = google_project.my_host_project.project_id
   service = "clouddebugger.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "cloudfunctions_service" {
   project = google_project.my_host_project.project_id
   service = "cloudfunctions.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "cloudkms_service" {
   project = google_project.my_host_project.project_id
   service = "cloudkms.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "cloudresourcemanager_service" {
   project = google_project.my_host_project.project_id
   service = "cloudresourcemanager.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "cloudtrace_service" {
   project = google_project.my_host_project.project_id
   service = "cloudtrace.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "datastore_service" {
   project = google_project.my_host_project.project_id
   service = "datastore.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "iam_service" {
   project = google_project.my_host_project.project_id
   service = "iam.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "iamcredentials_service" {
   project = google_project.my_host_project.project_id
   service = "iamcredentials.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "logging_service" {
   project = google_project.my_host_project.project_id
   service = "logging.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "monitoring_service" {
   project = google_project.my_host_project.project_id
   service = "monitoring.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "pubsub_service" {
   project = google_project.my_host_project.project_id
   service = "pubsub.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "servicemanagement_service" {
   project = google_project.my_host_project.project_id
   service = "servicemanagement.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "servicenetworking_service" {
   project = google_project.my_host_project.project_id
   service = "servicenetworking.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "serviceusage_service" {
   project = google_project.my_host_project.project_id
   service = "serviceusage.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "sourcerepo_service" {
   project = google_project.my_host_project.project_id
   service = "sourcerepo.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "sql_component_service" {
   project = google_project.my_host_project.project_id
   service = "sql-component.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "sqladmin_service" {
   project = google_project.my_host_project.project_id
   service = "sqladmin.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "storage_api_service" {
   project = google_project.my_host_project.project_id
   service = "storage-api.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "storage_component_service" {
   project = google_project.my_host_project.project_id
   service = "storage-component.googleapis.com"

   disable_dependent_services = true
}

resource "google_project_service" "storage_service" {
   project = google_project.my_host_project.project_id
   service = "storage.googleapis.com"

   disable_dependent_services = true
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
  workload_identity_pool_id = "wip-${var.integration_name}"
  display_name              = "wip-${var.integration_name}"
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
  workload_identity_pool_provider_id = "idp-${var.integration_name}"
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
    command     = "gcloud iam workload-identity-pools create-cred-config projects/${google_project.my_host_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.create_wip.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.add_provider.workload_identity_pool_provider_id} --service-account=${google_service_account.sa_for_hostproject.email} --output-file=credentials.json --aws"
    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [google_service_account_iam_binding.workload_identity_binding]
}


resource "null_resource" "project_list" {
  provisioner "local-exec" {
    command     = var.integration_projects == "" ? "gcloud projects list --filter 'lifecycleState: ACTIVE ' --format=\"json\" | jq -c > project_list.json" : "gcloud projects list --filter=${join(",",formatlist("'project_id:%s'" ,replace(var.integration_projects, "," , " OR project_id:")))} --format=\"json\" | jq -c > project_list.json"

    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [data.google_projects.my-org-projects]
}

