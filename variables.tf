variable "organization_id" {
  type        = string
  description = "The GCP parent organizations id where planning to create host projects and resources. "
}

variable "integration_projects" {
  type        = string
  description = "Projects need for integration. "
  default     = ""
}

variable "host_folder_name" {
  type        = string
  description = "The folder where host project will be created."
  default     = "uptycs"
}

variable "host_project_id" {
  type        = string
  description = "The GCP project ID where planning to create resources"
  default     = ""
}

variable "host_project_tags" {
  default     = {"uptycs-integration"="true"}
  description = "(Optional) host project tags"
  type        = map(string)
}

variable "service_account_name" {
  type        = string
  description = "The GCP service account name."
  default     = "sa-for-uptycs"
}

variable "gcp_workload_identity" {
  type        = string
  description = "Workload Identity Pool to allow Uptycs integration via AWS federation."
  default     = "wip-uptycs"

}

variable "gcp_wip_provider_id" {
  type        = string
  description = "Workload Identity Pool provider ID allow to add cloud provider."
  default     = "wip-provider-uptycs"
}

variable "host_aws_account_id" {
  type        = string
  description = "The deployer host AWS account ID."
}

variable "host_aws_instance_role" {
  type        = string
  description = "The attached deployer host AWS role name."
}

