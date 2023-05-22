# Terraform GCP module - Organization Integration for Uptycs

This module provides the required GCP resources to integrate a GCP organization with Uptycs.

It integrates multiple child projects available under the GCP organization.

It creates the following resources:

* Service Account, Workload Identity Pool & Identity provider under host project
* For a selected single project or for all projects in the organization, it adds IAM read permissions to allow Uptycs to collect the telemetry
* Provides the following read permissions for the Service Account created:
  * roles/iam.securityReviewer
  * roles/bigquery.resourceViewer
  * roles/pubsub.subscriber
  * roles/viewer
  * roles/browser

## Prerequisites

Ensure you have the following before you execute the Terraform Script:

- The following privileges to apply the configuration:
  * Organization Administrator
  * IAM Workload Identity Pool Admin (at Org level)
  * Service Account Admin (at Org level)
- The following APIs enabled on the host project:
  * IAM Service Account Credentials API
  * Cloud Resource Manager API
  * Cloud Pub/Sub API  (Conditional)
- The `terraform` version should be >= 1.2.5.
- The `gcloud` is required to get authenticated and generate the credentials file.

## Authentication

To authenticate GCP account using gcloud use the following command:

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
     source                    = "uptycslabs/gcp-integration/google"
     organization_id           = "<GCP-ORGANIZATION-ID>"
     integration_name          = "uptycs-int-20220101"
     service_account_name      = "sa-for-uptycs"

     # Select an existing project from your organization to host resources created by this configuration
     host_project_id = "<Host-Project-ID>"

     # Set this to true If you want to give permission at organization level
     # Set this to false otherwise (If you want to give permissions per child project)
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
2. **Init, Plan and Apply**

   **Inputs**


   | Name                      | Description                                                           | Type           | Default                 |
   | ------------------------- | --------------------------------------------------------------------- | -------------- | ----------------------- |
   | organization_id           | The GCP parent organization ID where resources are created            | `string`       | Required                |
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

- Update `integration_name` to specify the name of the resources WIP and IdP.
- Notes on `terraform destroy`:
  - Soft deleted provider can be restored using `UndeleteWorkloadIdentityPoolProvider`
  - The same `integration_name` cannot be re-used until the WIP is permanently deleted
  - Same WIP cannot be created again
- Run the command returned by `credential-file-gen-command` to re-generate the `credentials.json` file.
