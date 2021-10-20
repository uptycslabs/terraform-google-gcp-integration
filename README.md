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

## Requirements

These sections describe requirements for using this module.
The following dependencies must be available:

### 1. User & IAM

* The user account should have access to the GCP project for perform operation.
* Service account or user credentials with the following privileged roles must be used to provision the resources of this module:
  
  * To manage multiple projects & folders User/Principal need to provision below roles in organization label.
    * projectCreator
    * Folder Admin
    * IAM Workload Identity Pool Admin

### 2. Install terraform

This module is meant for use with Terraform version = "~> 3.61.0".

### 3. Install Google Cloud SDK

### 4. Authenticate

```
Login with ADC
  - "gcloud auth application-default login"
```

### 5. Use terraform module steps

  * Create a `filename.tf` file, paste below codes and modify as needed.
```
module "create-gcp-cred" {
  source                    = "github.com/uptycslabs/terraform-google-gcp-integration"
  organization_id           = "100000000000"   
  host_aws_account_id       = "123456789123"
  host_aws_instance_role    = "Role_integration"
}


output "regenerate-cred-config-command" {
  value = module.create-gcp-cred.regenerate-cred-config-command
}

output "integration-projects-list" {
  value = module.create-gcp-cred.integration-projects-list
}

output "host-project-id" {
  value = module.create-gcp-cred.host-project-id
}
```
### Notes:-
  * For more input parameters please follow below ##Inputs section and modify if required.
  * By default integration_projects will filter all ACTIVE projects for integration , pass project ids with comma-separated for restriction or use python script for more filters. 

### 6.Execute Terraform script to get credentials.json and project-list.json
```
$ terraform init
$ terraform plan  # Warning :- Please verify carefully before apply .
$ terraform apply # NOTE: Once terraform successfully applied, it will create "credentials.json" and "project-list.json" files.
```

### Inputs

| Name                      | Description                                                          | Type          | Default          |
| ------------------------- | -------------------------------------------------------------------- | ------------- | ---------------- |
| organization_id           | The GCP parent organizations id where resources will be created.     | `string`      | `""`             |
| host_folder_name          | The folder where host project will be created.                       | `string`      | `"uptycs"`       |
| host_project_id           | The value of host Project ID .                                       | `string`      | `"uptycs-<auto generated has value>"`|
| service_account_name      | The service account name which will be created in host project.      | `string`      | `"sa-for-uptycs"`|
| host_project_tags         | (Optional) host project tags .                                       | `map(string)` | `{}`             |
| integration_projects      | Projects need for integration ,pass project ids with comma-separated string if any. Ex:- "project1,project2"| `string` | `""` |
| host_aws_account_id       | The deployer host aws account id.                                    | `string`      | `""`             |
| host_aws_instance_role    | The attached deployer host aws role name.                            | `string`      | `""`             |
| gcp_workload_identity     | Workload Identity Pool to allow Uptycs integration via AWS federation| `string`      | `"wip-uptycs"`   |
| gcp_wip_provider_id       | Workload Identity Pool provider id allow to add cloud provider       | `string`      | `"wip-provider-uptycs"`|


### Outputs

| Name                            | Description                                  |
| ------------------------------- | -------------------------------------------- |
| regenerate-cred-config-command  | For creating again same cred config json file.|
| host-project-id                 | It will return host project id.  |
| integration-projects-list       | It will return projects list based on input patterns for integration .|


### Notes

1. Workload Identity Pool is soft-deleted and permanently deleted after approximately 30 days.
     - Soft-deleted provider can be restored using `UndeleteWorkloadIdentityPoolProvider`. ID cannot be re-used until the WIP is permanently deleted.
     - After `terraform destroy`, same WIP can't be created again. Modify `gcp_workload_identity` value if required.
2. Same host project id can't be used again after terraform destroy .
3. `credentials.json` is only created once. To re create the file use command returned by `regenerate-cred-config-command` output.
4. `project-list.json` will be created once apply done , Get json data for UI integration  .


## (Optional) Requirements and Use of python script to filter integration projects.

### 1. Install Google Cloud SDK
### 2. Install python3, google-api-python-client & oauth2client
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

* Run python script to get projects list 
```
    python3 get-filter-projects.py '{"project_ids_include_patterns":"*ops*,dev*", "folder_ids_include":"12345678,77784655", "project_ids_exclude": "test-ops-100,smart-project-3000"}'
```
* Notes : `"project_ids_include_patterns" : "*" and "folder_ids_include": "*"  these can be * in case of all projects and folders respectively.`
