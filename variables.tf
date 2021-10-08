variable "organizations_id" {
  type        = string
  description = "The GCP parent organizations id where planning to create host projects and resources. "
}

variable "does_host_project_exists" {
  type        = bool
  description = "Set true if you want to use existing project as host project."
  default     = false
}

variable "host_folder_name" {
  type        = string
  description = "The folder where host project will be created."
}

variable "host_project_id" {
  type        = string
  description = "The GCP project ID where planning to create resources"
}

variable "host_project_tags" {
  default     = {}
  description = "(Optional) host project tags"
  type        = map(string)
}

variable "service_account_name" {
  type        = string
  description = "The GCP service account name."
}

variable "projects_input_patterns" {
  type = map
  description                    = "Filtering projects based on input patterns for integration. "
  default = {
    folder_ids_include           = ""
    project_ids_include_patterns = ""
    project_ids_exclude          = ""
  }
}

variable "gcp_workload_identity" {
  type        = string
  description = "Workload Identity Pool to allow Uptycs integration via AWS federation."
}

variable "gcp_wip_provider_id" {
  type        = string
  description = "Workload Identity Pool provider ID allow to add cloud provider."
}

variable "host_aws_account_id" {
  type        = string
  description = "The deployer host AWS account ID."
}

variable "host_aws_instance_role" {
  type        = string
  description = "The attached deployer host AWS role name."
}

