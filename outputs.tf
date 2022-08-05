output "host-project-id" {
  value = data.google_project.my_host_project.project_id
}

output "integration-name" {
  value = var.integration_name
}

output "credential-file-gen-command" {
  description = "Command to generate the credentials JSON file"
  value       = "gcloud iam workload-identity-pools create-cred-config projects/${data.google_project.my_host_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.create_wip.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.add_provider.workload_identity_pool_provider_id} --service-account=${google_service_account.sa_for_hostproject.email} --output-file=credentials.json --aws"
}
