output "host-project-id" {
  value = google_project.my_host_project.project_id
}

output "regenerate-cred-config-command" {
  description = "For creating again same cred config json file"
  value       = "gcloud iam workload-identity-pools create-cred-config projects/${google_project.my_host_project.number}/locations/global/workloadIdentityPools/${var.gcp_workload_identity}/providers/${var.gcp_wip_provider_id} --service-account=${google_service_account.sa_for_hostproject.email} --output-file=credentials.json --aws"
}

output "integration-projects-list" {
  value = var.integration_projects == "" ? join(",",data.google_projects.my-org-projects.projects[*].project_id) : var.integration_projects
}

output "integration-projects-list-command" {
  value = var.integration_projects == "" ? "gcloud projects list --filter 'lifecycleState: ACTIVE AND projectId != ${google_project.my_host_project.project_id}' --format=\"json\" | jq -c" : "eval $(echo ${var.integration_projects} | sed -e 's/^/gcloud projects list --filter=\"project_id:/g' |sed -e 's/,/ OR project_id:/g' | sed -e 's/$/\" --format=\"json\" | jq -c/g')"
}