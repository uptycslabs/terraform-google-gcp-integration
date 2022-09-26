# Terraform GCP module - Organization Integration for Uptycs

This module provides the required GCP resources to integrate a GCP organization with Uptycs.

It integrates multiple child projects available under the organization.

It creates the following resources:

* Service Account, Workload Identity Pool & Identity provider under host-project
* For each project selected or for all projects in the organization, it adds IAM read permissions so Uptycs can collect telemetry
* Read permissions for the Service Account created:
  * roles/iam.securityReviewer
  * roles/bigquery.resourceViewer
  * roles/pubsub.subscriber
  * roles/viewer
  * roles/browser

## Prerequisites

Ensure you have the following before you execute the Terraform Script:

- You need to have the following privileges to apply the configuration:

  * Organization Administrator
  * IAM Workload Identity Pool Admin (at Org level)
  * Service Account Admin (at Org level)
- You need to Enable following APIs in the host-project:
  * IAM Service Account Credentials API
  * Cloud Resource Manager API
  * Cloud Pub/Sub API
- `Terraform` version should be >= 1.2.5.
- `Gcloud` is required for authenticatication and to generate the credentials file.

## Authentication:

```
Login with ADC
- "gcloud auth application-default login"
```

## Terraform Script

To execute the Terraform script:

1. **Prepare .tf file**

   Create a `main.tf` file in a new folder. Copy and paste the following configuration and modify as required:

   ```
   module "create-gcp-cred" {
     source                    = "github.com/uptycslabs/terraform-google-gcp-integration"
     organization_id           = "<GCP-ORGANIZATION-ID>"
     integration_name          = "uptycs-int-20220101"
     service_account_name      = "sa-for-uptycs"

     # Select an existing project from your organization to host resources created by this configuration
     host_project_id = "<Host-Project-ID>"

     # Set to true, If you want to give permission at organization level
     # Set to false, If you want to give permissions at project level
     set_org_level_permissions = true

     # AWS account details
     # Copy Uptycs's AWS Account ID and Role from Uptycs' UI.
     # Uptycs' UI: "Cloud"->"GCP"->"Integrations"->"ORGANIZATION INTEGRATION"
     host_aws_account_id     = "<AWS account id>"
     host_aws_instance_roles  = ["Role_Allinone", "Role_PNode", "Role_Cloudquery"]
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

**Notes**:

- **If you set the flag `set_org_level_permissions` to `true`, the permissions at the organization level are attached to the service account. Any addition of a project to the organization is automatically integrated with Uptycs. You do not need to execute `step 2` again.**
- **If you set the flag `set_org_level_permissions` to `false`, proceed with `step 2`.**

2. **Init, Plan and Apply**

   **Inputs**


   | Name                      | Description                                                           | Type           | Default                 |
   | --------------------------- | ----------------------------------------------------------------------- | ---------------- | ------------------------- |
   | organization_id           | The GCP parent organizations ID where resources are created           | `string`       | Required                |
   | integration_name          | Unique phrase used to name the resources                              | `string`       | `"uptycs-int-20220101"` |
   | service_account_name      | The service account name that is created in the host project          | `string`       | `"sa-for-uptycs"`       |
   | host_project_id           | GCP Project ID under which Uptycs should create required resources    | `string`       | Required                |
   | host_aws_account_id       | AWS account ID of Uptycs - for federated identity                     | `string`       | Required                |
   | host_aws_instance_roles   | AWS role names of Uptycs - for identity binding                       | `list(string)` | Required                |
   | set_org_level_permissions | The flag to choose permissions at organization level or project level | `bool`         | true                    |

   **Outputs**


   | Name                        | Description                                |
   | ----------------------------- | -------------------------------------------- |
   | credential-file-gen-command | Command to generate credentials JSON file. |
   | host-project-id             | Host Project ID                            |


   ```
   $ terraform init
   $ terraform plan  # Please verify before applying
   $ terraform apply
   # Once terraform successfully applied, it will create "credentials.json" file
   ```

**Notes**:

- Update `integration_name` to change the name of the resources WIP and IdP.
- Notes on `terraform destroy`
  - Soft deleted provider can be restored using `UndeleteWorkloadIdentityPoolProvider`
  - `integration_name` cannot be re-used until the WIP is permanently deleted
  - Same WIP cannot be created again
- Run the command returned by `credential-file-gen-command` to re-generate the `credentials.json` file.
