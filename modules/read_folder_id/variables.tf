variable "organization_id" {
  type = string
  description = "The GCP parent organization ID"
}
variable "parent_folder_name" {
 type = string
 description = "system gsuite folder name"
}

variable "folder_name" {
  type = string
  description = "app script folder in system gsuite"
}

variable "host_project_id" {
  type = string
  description = "Project ID to host resources created as part of integration."
}

