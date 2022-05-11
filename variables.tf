variable "organization_id" {
  type        = string
  description = "The GCP parent organization ID that is getting integrated"
}

variable "integration_projects" {
  type        = string
  description = "List of projects to be integrated"
  default     = ""
}

variable "integration_name" {
  type        = string
  description = "Unique phrase. Used to name resources created by the plan"
}

variable "host_project_tags" {
  default     = {}
  description = "(Optional) host project tags"
  type        = map(string)
}

variable "service_account_name" {
  type        = string
  description = "The GCP service account name."
  default     = "sa-for-uptycs"
}

variable "host_aws_account_id" {
  type        = string
  description = "The deployer host AWS account ID."
}

variable "host_aws_instance_role" {
  type        = string
  description = "The attached deployer host AWS role name."
}

