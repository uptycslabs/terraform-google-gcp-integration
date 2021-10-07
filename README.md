# Terraform GCP IAM module

## Overview
Customers are expected to have high number of GCP projects. So this module can handle integration of a group of projects at a time. 
That allows you to create GCP credential config in Google Cloud Platform projects which will be used to get GCP data from AWS environment.

This module will create below resources:-
 * It creates host folder, host project , service account, work pool identity & add cloud provider to it.
 * It will update IAM permission of each selected project to allow access by the new Service Account.
 * It will attach below policies to service account of host projects and other integration projects.
     * roles/iam.securityReviewer
     * roles/bigquery.resourceViewer
     * roles/pubsub.subscriber
     * roles/viewer

# Requirements

These sections describe requirements for using this module.
The following dependencies must be available:

## 1. User & IAM

* The user account should have access to the GCP project for perform operation.
* Service account or user credentials with the following privileged roles must be used to provision the resources of this module:
  
  * To manage multiple projects & folders User/Principal need to provision below roles in organization label.
    * projectCreator
    * Folder Admin
    * IAM Workload Identity Pool Admin

## 2. Install terraform

This module is meant for use with Terraform version = "~> 3.61.0".

## 3. Install Google Cloud SDK 

## 4. Install python3, google-api-python-client & oauth2client
```
pip3 install --upgrade google-api-python-client
pip3 install --upgrade oauth2client
```

* Notes :- If error comes to install google-api-python-client and oauth2client then go for install these libraries in a virtualenv using pip3.
* Installation in Mac/Linux
```
pip3 install virtualenv
virtualenv <your-env>
source <your-env>/bin/activate
<your-env>/bin/pip3 install --upgrade google-api-python-client
<your-env>/bin/pip3 install --upgrade oauth2client
```

## 5. Authenticate

```
Login with ADC
  - "gcloud auth application-default login"
```

## 6. Use terraform module steps

  * Create a <filename>.tf file, paste below codes and modify as needed.
```
module "create-gcp-cred" {
  source                    = "github.com/uptycslabs/terraform-google-cred-config"
  gcp_region                = "us-east1"
  parent_organizations_id   = "1234567890"
  host_folder_name          = "test-folder"
  host_project_id           = "test-project-q683x6"
  service_account_name      = "sa-for-cldquery"
  
  # (Optional) host project tags
  host_project_tags         = {"uptycs-integration"="true"}  
  
  # Pass patterns to filter projects for integration
  projects_input_patterns   =  
                            {
                             folder_id_include           = "11111111111,222222222 "
                             project_id_include_pattern  = "^ops*,*racer*,project-id1,project-id2"
                             project_id_exclude          = "test-project-503,test-racer-32561,dev-project-327714"
                            }

      
  # AWS account details
  host_aws_account_id     = "< AWS account id >"
  host_aws_instance_role  = "< AWS role >"

  # Modify if required
  gcp_workload_identity = "wip-uptycs"
  gcp_wip_provider_id   = "aws-id-provider-test"
}


output "command-to-generate-gcp-cred-config" {
  value = module.create-gcp-cred.command-to-generate-gcp-cred-config
}

output "filtered-projects-details" {
  value = module.create-gcp-cred.filtered-projects-details
}

```

## Inputs

| Name                      | Description                                                                                                        | Type          | Default          |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------- | ---------------- |
| gcp_region                | The GCP project region where planning to create resources.                                                         | `string`      | `us-east-1`      |
| parent_organizations_id   | The GCP parent organizations id where you wants create resources.                                                  | `string`      | `""`             |
| host_folder_name          | The folder where host project will be created.                                                                     | `string`      | `""`             |
| host_project_id           | Pass unique host project ID where planning to create resources.                                                    | `string`      | `""`             |
| service_account_name      | Pass new service account name.                                                                                     | `string`      | `"sa-for-test"`  |
| host_project_tags         | (Optional) host project tags .                                                                                     | `map(string)` | `{"uptycs-integration"="true"}` |
| projects_input_patterns   | Filtering projects based on input patterns for integration.  { folder_id_include = "" project_id_include_pattern = "" project_id_exclude = "" }                                                       | `map(string)` | `{}`             |
| host_aws_account_id       | The deployer host aws account id.                                                                                  | `number`      | `""`             |
| host_aws_instance_role    | The attached deployer host aws role name.                                                                          | `string`      | `""`             |
| gcp_workload_identity     | Workload Identity Pool to allow Uptycs integration via AWS federation                                              | `string`      | `""`             |
| gcp_wip_provider_id       | Workload Identity Pool provider id allow to add cloud provider                                                     | `string`      | `""`             |


## Outputs

| Name                    | Description                                  |
| ----------------------- | -------------------------------------------- |
| command-to-generate-gcp-cred-config  | For creating again same cred config json data ,please use command return by "command-to-generate-gcp-cred-config" |
| filtered-projects-details     | Filtering projects based on input patterns for integration in json format. |

## Notes

1. Workload Identity Pool is soft-deleted and permanently deleted after approximately 30 days.
     - Soft-deleted provider can be restored using `UndeleteWorkloadIdentityPoolProvider`. ID cannot be re-used until the WIP is permanently deleted.
     - After `terraform destroy`, same WIP can't be created again. Modify `gcp_workload_identity` value if required.

2. `credentials.json` is only created once. To re create the file use command returned by `command-to-generate-gcp-cred-config` output.
3. `project-list.json` will be created once apply done , Get json data for UI integration , for regenerate the json data use `terraform output -json filtered-projects-details` .

## 6.Execute Terraform script to get credentials JSON
```
$ terraform init
$ terraform plan
$ terraform apply # NOTE: Once terraform successfully applied, it will create "credentials.json" and "project-list.json" files.
$ terraform output -json filtered-projects-details
```
