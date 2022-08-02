variable "organization_id" {
  type        = string
  description = "The GCP parent organization ID that is getting integrated"
}

variable "host_project_id" {
  type        = string
  description = "Project ID to host resources created as part of integration."
}

variable "integration_name" {
  type        = string
  description = "Unique tag. Used to name resources created by the plan"
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

