output "command-to-generate-gcp-cred-config" {
  value = "gcloud iam workload-identity-pools create-cred-config projects/${var.is_host_project_exists == false ? google_project.my_host_project[0].number : data.google_project.get_host_project_id[0].number}/locations/global/workloadIdentityPools/${var.gcp_workload_identity}/providers/${var.gcp_wip_provider_id} --service-account=${google_service_account.sa_for_hostproject.email} --output-file=credentials.json --aws"
}

output "filtered-projects-details" {
  value = "[${data.external.filters_p.result.details}]"
}