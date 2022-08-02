output "host-project-id" {
  value = data.google_project.my_host_project.project_id
}

output "regenerate-cred-config-command" {
  description = "For creating again same cred config json file"
  value       = "gcloud iam workload-identity-pools create-cred-config projects/${data.google_project.my_host_project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.create_wip.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.add_provider.workload_identity_pool_provider_id} --service-account=${google_service_account.sa_for_hostproject.email} --output-file=credentials.json --aws"
}

output "projects_all" {
  description = "Projects list"
  value       = data.google_projects.my-org-projects.projects[*].project_id
}
output "projects_w_tag" {
  description = "Projects with tag"
  value       = local.projects_with_tag
}
output "services_to_enable" {
  description = "services to enable"
  value       = local.services_to_enable
}
