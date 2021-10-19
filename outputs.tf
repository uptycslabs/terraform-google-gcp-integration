output "host-project-id" {
  value = google_project.my_host_project.project_id
}

output "regenerate-cred-config-command" {
  description = "For creating again same cred config json file"
  value       = "gcloud iam workload-identity-pools create-cred-config projects/${google_project.my_host_project.number}/locations/global/workloadIdentityPools/${var.gcp_workload_identity}/providers/${var.gcp_wip_provider_id} --service-account=${google_service_account.sa_for_hostproject.email} --output-file=credentials.json --aws"
}

output "integration-projects-list" {
  value = var.integration_projects == "" ? toset( data.google_projects.my-org-projects.projects[*].project_id) : toset( split(",",var.integration_projects))
}
