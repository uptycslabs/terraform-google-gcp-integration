data "google_projects" "my-org-projects" {
  filter = "lifecycleState:ACTIVE"
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
  system_gsuite_folders = [for each in data.google_folders.my-org-folders.folders : each.name if each.display_name == var.parent_folder_name]

  # Get appscript folder in the gsuite folder
  system_app_script_folders = length(local.system_gsuite_folders) == 0 ? []: [for each in data.google_folders.app_script_folders[0].folders : each.name if each.display_name == var.folder_name]

  projects_with_tag = toset([for each in data.google_projects.my-org-projects.projects : each.project_id if contains(keys(each.labels), "uptycs-integration")])

  # Exclude the projects in the path Organization root > system-gsuite > apps-script
  all_project_ids = length(local.system_app_script_folders) == 0 ? toset([for each in data.google_projects.my-org-projects.projects : each.project_id]) : toset([for each in data.google_projects.my-org-projects.projects : each.project_id if each.parent.id != (split("/",local.system_app_script_folders[0]))[1]])

  projects_to_integrate = length(local.projects_with_tag) != 0 ? setunion(local.projects_with_tag, [var.host_project_id]) : local.all_project_ids
  
}
