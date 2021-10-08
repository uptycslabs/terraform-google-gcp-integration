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
  * For inputs parameters please refer ## Inputs section below.
```
module "create-gcp-cred" {
  source                    = "github.com/uptycslabs/terraform-google-cred-config"
  organizations_id          = "1234567890"
  host_folder_name          = "test-folder"
  host_project_id           = "test-project-q683x6"
  service_account_name      = "sa-for-test"
  
  # (Optional) host project tags
  host_project_tags         = {"uptycs-integration"="true"}  
  
  # Pass patterns to filter projects for integration
  projects_input_patterns   =  
                            {
                             folder_ids_include           = "11111111111,222222222 "
                             project_ids_include_patterns = "^ops*,*dev*,project-id1,project-id2"
                             project_ids_exclude          = "test-project-503,test-racer-32561,dev-project-327714"
                            }

      
  # AWS account details
  host_aws_account_id     = "< AWS account id >"
  host_aws_instance_role  = "< AWS role >"

  # Modify if required
  gcp_workload_identity = "wip-uptycs"
  gcp_wip_provider_id   = "aws-id-provider-test"
}


output "regenerate-cred-config-command" {
  value = module.create-gcp-cred.create-cred-config-command
}

output "integration-projects-list" {
  value = module.create-gcp-cred.integration-projects-list
}

output "host-project-id" {
  value = module.create-gcp-cred.host-project-id
}

```

## 7.Execute Terraform script to get credentials.json and project-list.json
```
$ terraform init
$ terraform plan  # Warning :- Please verify carefully before apply .
$ terraform apply # NOTE: Once terraform successfully applied, it will create "credentials.json" and "project-list.json" files.
```

## Inputs

| Name                      | Description                                                                                                        | Type          | Default          |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------- | ---------------- |
| organizations_id   | The GCP parent organizations id where you wants create resources.                                                  | `string`      | `""`             |
| host_folder_name          | The folder where host project will be created.                                                                     | `string`      | `""`             |
| host_project_id           | Pass unique host project ID where planning to create resources.                                                    | `string`      | `""`             |
| service_account_name      | Pass new service account name.                                                                                     | `string`      | `""`  |
| host_project_tags         | (Optional) host project tags .                                                                                     | `map(string)` | `{}` |
| projects_input_patterns   | Filtering projects based on input patterns for integration.                                                        | `map(string)` | `{ folder_ids_include = "" project_ids_include_patterns = "" project_ids_exclude = "" }`             |
| host_aws_account_id       | The deployer host aws account id.                                                                                  | `number`      | `""`             |
| host_aws_instance_role    | The attached deployer host aws role name.                                                                          | `string`      | `""`             |
| gcp_workload_identity     | Workload Identity Pool to allow Uptycs integration via AWS federation                                              | `string`      | `""`             |
| gcp_wip_provider_id       | Workload Identity Pool provider id allow to add cloud provider                                                     | `string`      | `""`             |


## Outputs

| Name                    | Description                                  |
| ----------------------- | -------------------------------------------- |
| regenerate-cred-config-command  | For creating again same cred config json file. |
| host-project-id                 | It will return host project id.  |
| integration-projects-list       | It will return projects list based on input patterns for integration . |


## Notes

1. Workload Identity Pool is soft-deleted and permanently deleted after approximately 30 days.
     - Soft-deleted provider can be restored using `UndeleteWorkloadIdentityPoolProvider`. ID cannot be re-used until the WIP is permanently deleted.
     - After `terraform destroy`, same WIP can't be created again. Modify `gcp_workload_identity` value if required.

2. `credentials.json` is only created once. To re create the file use command returned by `regenerate-cred-config-command` output.
3. `project-list.json` will be created once apply done , Get json data for UI integration  .
