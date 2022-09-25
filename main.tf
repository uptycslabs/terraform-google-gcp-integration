data "google_projects" "my-org-projects" {
  filter = "lifecycleState:ACTIVE"
}

data "google_project" "my_host_project" {
  project_id = var.host_project_id
}

data "google_folders" "my-org-folders" {
  parent_id = "organizations/${var.organization_id}"
}

data "google_folders" "app_script_folders" {
  count = length(local.system_gsuite_folders) == 0 ? 0 : 1
  parent_id = local.system_gsuite_folders[0]
}

locals {
  # Get gsuite folder in organization 
  system_gsuite_folders = [for each in data.google_folders.my-org-folders.folders : each.name if each.display_name == "uptycs"]
  # Get appscript folder in the gsuite folder
  system_app_script_folders = length(local.system_gsuite_folders) == 0 ? []: [for each in data.google_folders.app_script_folders[0].folders : each.name if each.display_name == "uptycs-sub-folder1"]
  
  projects_with_tag = toset([for each in data.google_projects.my-org-projects.projects : each.project_id if contains(keys(each.labels), "uptycs-integration")])
  
  # Exclude the projects in the path Organization root > system-gsuite > apps-script
  all_project_ids = length(local.system_app_script_folders) == 0 ? toset([for each in data.google_projects.my-org-projects.projects : each.project_id]) : toset([for each in data.google_projects.my-org-projects.projects : each.project_id if each.parent.id != (split("/",local.system_app_script_folders[0]))[1]])
  
  projects_to_integrate = length(local.projects_with_tag) != 0 ? setunion(local.projects_with_tag, [var.host_project_id]) : local.all_project_ids
  /*service_names = [
                     "bigquery", "bigquerymigration", "bigquerystorage", "cloudapis",
                     "clouddebugger", "cloudfunctions", "cloudkms", "cloudresourcemanager",
                     "cloudtrace", "datastore", "iam", "iamcredentials", "logging", "monitoring",
                     "pubsub", "servicemanagement", "servicenetworking", "serviceusage", "sourcerepo",
                     "sql-component", "sqladmin", "storage-api", "storage-component", "storage"
                   ]*/
  //services_to_enable = toset([for each in local.service_names : "${each}.googleapis.com"])
}

//resource "google_project_service" "services_enable" {
//   for_each = local.services_to_enable
//   project  = data.google_project.my_host_project.project_id
//   service  = each.key
//
//   disable_dependent_services = true
//}

resource "google_service_account" "sa_for_hostproject" {
  project      = data.google_project.my_host_project.project_id
  account_id   = var.service_account_name
  display_name = var.service_account_name
  description  = "Service Account for Intergration"
}

resource "google_project_iam_member" "bind_viewer_SA_to_filter_projects" {
  for_each   = var.set_org_level_permissions == true ? [] : local.projects_to_integrate
  project    = each.key
  role       = "roles/viewer"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_organization_iam_member" "bind_projects_browser_SA_to_Organization" {
  org_id    = var.organization_id
  role       = "roles/browser"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_organization_iam_member" "bind_Viewer_SA_to_Organization" {
  count = var.set_org_level_permissions == true ? 1 : 0
  org_id    = var.organization_id
  role       = "roles/viewer"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_organization_iam_member" "bind_resourceViewer_SA_to_Organization" {
  count = var.set_org_level_permissions == true ? 1 : 0
  org_id    = var.organization_id
  role       = "roles/bigquery.resourceViewer"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_organization_iam_member" "bind_pubsub_SA_to_Organization" {
  count = var.set_org_level_permissions == true ? 1 : 0
  org_id    = var.organization_id
  role       = "roles/pubsub.subscriber"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_organization_iam_member" "bind_securityReviewer_SA_to_Organization" {
  count = var.set_org_level_permissions == true ? 1 : 0
  org_id    = var.organization_id
  role       = "roles/iam.securityReviewer"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_project_iam_member" "bind_resourceViewer_SA_to_filter_projects" {
  for_each   = var.set_org_level_permissions == true ? [] : local.projects_to_integrate
  project    = each.key
  role       = "roles/bigquery.resourceViewer"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"

}

resource "google_project_iam_member" "bind_pubsub_SA_to_filter_projects" {
  for_each   = var.set_org_level_permissions == true ? [] : local.projects_to_integrate
  project    = each.key
  role       = "roles/pubsub.subscriber"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_project_iam_member" "bind_securityReviewer_SA_to_filter_projects" {
  for_each   = var.set_org_level_permissions == true ? [] : local.projects_to_integrate
  project    = each.key
  role       = "roles/iam.securityReviewer"

  member     = "serviceAccount:${google_service_account.sa_for_hostproject.email}"
}

resource "google_iam_workload_identity_pool" "create_wip" {
  provider                  = google-beta
  project                   = data.google_project.my_host_project.project_id
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
  project                            = data.google_project.my_host_project.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.create_wip.workload_identity_pool_id
  workload_identity_pool_provider_id = "idp-${var.integration_name}"
  aws {
    account_id                       = var.host_aws_account_id
  }
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.sa_for_hostproject.name

  role               = "roles/iam.workloadIdentityUser"
  members = [for each in var.host_aws_instance_roles : format("principalSet://iam.googleapis.com/projects/%s/locations/global/workloadIdentityPools/%s/attribute.aws_role/arn:aws:sts::%s:assumed-role/%s", data.google_project.my_host_project.number, google_iam_workload_identity_pool.create_wip.workload_identity_pool_id, var.host_aws_account_id, each)]
  depends_on = [google_iam_workload_identity_pool.create_wip]
}

resource "null_resource" "cred_config_json" {
  provisioner "local-exec" {
    command     = "gcloud iam workload-identity-pools create-cred-config projects/${data.google_project.my_host_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.create_wip.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.add_provider.workload_identity_pool_provider_id} --service-account=${google_service_account.sa_for_hostproject.email} --output-file=credentials.json --aws"
    interpreter = ["/bin/sh", "-c"]
  }
  depends_on = [google_service_account_iam_binding.workload_identity_binding]
}
