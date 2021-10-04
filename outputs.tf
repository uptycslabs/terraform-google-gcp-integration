output "new-service-account-email" {
  description = "The deployed Service Account's email-id"
  value       = google_service_account.sa_for_hostproject.email
}

output "command-to-generate-gcp-cred-config" {
  value = "gcloud iam workload-identity-pools create-cred-config projects/${var.is_host_project_exists == false ? google_project.my_host_project[0].number : data.google_project.get_host_project_id[0].number}/locations/global/workloadIdentityPools/${var.gcp_workload_identity}/providers/${var.gcp_wip_provider_id} --service-account=${google_service_account.sa_for_hostproject.email} --output-file=credentials.json --aws"
}


output "filter-integration-project-list" {
  value = tolist( split(",",data.external.filters_p.result.final_projects_ids))
}

