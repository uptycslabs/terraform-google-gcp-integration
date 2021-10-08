output "host-project-id" {
  value = var.does_host_project_exists == false ? google_project.my_host_project[0].project_id : data.google_project.get_host_project_id[0].project_id
}

output "regenerate-cred-config-command" {
  description = "For creating again same cred config json file"
  value       = "gcloud iam workload-identity-pools create-cred-config projects/${var.does_host_project_exists == false ? google_project.my_host_project[0].number : data.google_project.get_host_project_id[0].number}/locations/global/workloadIdentityPools/${var.gcp_workload_identity}/providers/${var.gcp_wip_provider_id} --service-account=${google_service_account.sa_for_hostproject.email} --output-file=credentials.json --aws"
}

output "integration-projects-list" {
  value = data.external.filters_p.result.final_projects_ids
}
