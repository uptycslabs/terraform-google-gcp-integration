variable "gcp_region" {
  type        = string
  description = "The GCP project region where planning to create resources "
  default     = "us-east1"
}

variable "parent_organizations_id" {
  type        = string
  description = "The GCP parent organizations id where planning to create host projects and resources. "
  default     = "604124743451"
}

variable "is_host_project_exists" {
  type        = bool
  description = "Set true if you want to use existing project as host project."
  default     = false
}

variable "host_folder_name" {
  type        = string
  description = "The folder where host project will be created."
  default     = "test-folder"
}

variable "host_project_id" {
  type        = string
  description = "The GCP project ID where planning to create resources"
  default     = "test-project-q683x6"
}

variable "host_project_tags" {
   //default     = {}
  default = {"uptycs-integration"="true"}
  description = "(Optional) host project tags"
  type        = map(string)
}

variable "service_account_name" {
  type        = string
  description = "The GCP service account name."
  default     = "cacharya-ops-sa"
}

variable "projects_input_patterns" {
  type = map
  description = "Filtering projects based on input patterns for integration. "
  default = {
    folder_id_include           = "687182092621"
    project_id_include_pattern  = "^ops*,*ops*,disembark,pork"
    project_id_exclude          = "cacharya-ops-503,constant-racer-32561,dev-project-327714"
  }
}



variable "gcp_workload_identity" {
  type        = string
  description = "Workload Identity Pool to allow Uptycs integration via AWS federation."
  default     = "wip-test"
}

variable "gcp_wip_provider_id" {
  type        = string
  description = "Workload Identity Pool provider ID allow to add cloud provider."
  default     = "aws-id-provider-test"
}

variable "host_aws_account_id" {
  type        = string
  description = "The deployer host AWS account ID."
  default     = "014988765081"
}

variable "host_aws_instance_role" {
  type        = string
  description = "The attached deployer host AWS role name."
  default     = "Test_Role_Allinone"
}

