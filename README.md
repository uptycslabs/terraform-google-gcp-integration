# Terraform GCP module - Organization Integration for Uptycs 

## Overview
This module will provision the required GCP resources inorder to integrate GCP organization with Uptycs.

This will module will integrate multiple child projects under the organization.

This module will create following resources:
 * Service Account, Workload Identity Pool & Identity provider under host-project
 * For each project selected, it will add IAM read permissions (described below) so Uptycs can collect telemetry
 * Read permissions for the created Service Account
     * roles/iam.securityReviewer
     * roles/bigquery.resourceViewer
     * roles/pubsub.subscriber
     * roles/viewer

## Requirements
### 1. User & IAM
* You need to have the following privileges to apply the configuration
    * Organization Administrator
    * IAM Workload Identity Pool Admin

### 2. Terraform
`terraform` version >= 1.2.5

### 3. gcloud CLI
`gcloud` is required to get authenticated and to generate credentials file

### 4. Authenticate 
```
Login with ADC
  - "gcloud auth application-default login"
```
## Terraform script

### 1. Prepare .tf file
  * Create a `main.tf` file in a new folder. Paste following configuration and modify as needed.
```
module "create-gcp-cred" {
  source                    = "github.com/uptycslabs/terraform-google-gcp-integration"
  organization_id           = "<GCP-ORGANIZATION-ID>"
  integration_name          = "uptycs-int-20220101"
  service_account_name      = "sa-for-uptycs"

  # Select an existing project from your organization to host resources created by this configuration
  host_project_id = "<Host-Project-ID>"

  # AWS account details
  # Copy Uptycs's AWS Account ID and Role from Uptycs' UI.
  # Uptycs' UI: "Cloud"->"GCP"->"Integrations"->"ORGANIZATION INTEGRATION"
  host_aws_account_id     = "<AWS account id>"
  host_aws_instance_roles  = ["<Role1>", "<Role2>"]
}

output "host-project-id" {
  value = module.create-gcp-cred.host-project-id
}

output "integration-name" {
  value = module.create-gcp-cred.integration-name
}

output "credential-file-gen-command" {
  value = module.create-gcp-cred.credential-file-gen-command
}

```
### 2. Init, Plan and Apply

#### Inputs
| Name                      | Description                                                          | Type          | Default          |
| ------------------------- | -------------------------------------------------------------------- | ------------- | ---------------- |
| organization_id           | The GCP parent organizations id where resources will be created.     | `string`      | Required         |
| integration_name          | Unique phrase. Used to name resources                                | `string`      | `"uptycs-int-20220101"`|
| service_account_name      | The service account name which will be created in host project.      | `string`      | `"sa-for-uptycs"`|
| host_project_id           | GCP Project ID that Uptycs should create required resources under    | `string`      | Required         |
| host_aws_account_id       | AWS account id of Uptycs - for federated identity                    | `string`      | Required         |
| host_aws_instance_roles   | AWS role names of Uptycs - for identity binding                      | `list(string)`| Required         |

#### Outputs
| Name                            | Description                                  |
| ------------------------------- | -------------------------------------------- |
| credential-file-gen-command     | Command to generate credentials JSON file.   |
| host-project-id                 | Host Project ID.                             |

```
$ terraform init
$ terraform plan  # Please verify before applying
$ terraform apply
# Once terraform successfully applied, it will create "credentials.json" file
```

### Notes
1. Change `integration_name` to change names of the resources host folder, project, wip and idp.
2. Notes on `terraform destroy`
     - Soft-deleted provider can be restored using `UndeleteWorkloadIdentityPoolProvider`.
     - ID cannot be re-used until the WIP is permanently deleted.
     - Same WIP can't be created again.
4. Run the command returned by `credential-file-gen-command` to re-generate `credentials.json`
