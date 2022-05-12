# Migrating Off Terraform Cloud

This demo is meant to accompany [this blog post](https://nedinthecloud.com/2022/03/03/migrating-state-data-off-terraform-cloud/) about how to migrate state off Terraform Cloud to either the `local` backend or `azurerm` backend. I'm not going to rehash all the details here, go [read the post](https://nedinthecloud.com/2022/03/03/migrating-state-data-off-terraform-cloud/)! The files in this directory can help you follow along with the post and see how the whole thing works. 

## Prerequisites

You're going to need a few things to follow along:

* Azure subscription with Admin level access
* Access to create a service principal on the Azure AD tenant associated with your subscription
* Terraform Cloud account and organization
* Azure CLI installed locally with a profile

## Remote State Setup

The `remote_state_setup` directory contains a terraform configuration that will generate the following resources:

* Azure service principal and application for managing state and deploying infrastructure
* Azure storage account and container for remote state data storage
* `backend.txt` file containing the additional configuration info for the `azurerm` backend

You'll need an Azure service principal to deploy infrastructure to Azure using Terraform Cloud. The output of the configuration includes the environment variables you will need to set in the Terraform Cloud workspace you'll be doing the initial deployment from.

## Main Configuration

The `main_config` directory contains a Terraform configuration that will deploy an Azure App Service instance, using Terraform Cloud as the state data backend. You will need to update the `cloud` block in the `terraform.tf` file to be your Terraform Cloud organization. You could also choose to change the workspace name or leave it as is.

To perform the initial deployment, update the `terraform.tf` file and run a `terraform init`. That will create the workspace in Terraform Cloud if it doesn't already exist. Then go into the workspace and set the follow environment variables with the output from the remote state setup config:

* ARM_CLIENT_ID
* ARM_CLIENT_SECRET
* ARM_SUBSCRIPTION_ID
* ARM_TENANT_ID

Terraform Cloud will use those credentials with its remote runner to deploy the infrastructure to Azure.

After setting the environment variables, run a `terraform apply` from the command line to deploy the infrastructure.

## Migrating to the Local Backend

To migrate your state data to a local backend, simply follow the process outlined in [the blog post](https://nedinthecloud.com/2022/03/03/migrating-state-data-off-terraform-cloud/):


1. In the `main_config` directory, create a `terraform.tfstate.d` directory with a `tfc-migration-test` subdirectory
   - `mkdir -p terraform.tfstate.d/tfc-migration-test`
1. Make a copy of the TFC state data, saving it to a `terraform.tfstate` file in the `tfc-migration-test` directory
   - `terraform state pull > terraform.tfstate.d/tfc-migration-test/terraform.tfstate`
1. Rename the `terraform.tfstate` file in the `.terraform` directory
   - `mv .terraform/terraform.tfstate .terraform/terraform.tfstate.old`
1. Comment out the `cloud` block in the `terraform.tf` file
1. Run `terraform init` to prepare the `local` backend
   - `terraform init`

That's it! You should be able to make an update to the config and run `terraform apply` successfully.

## Migrating to the AzureRM Backed

Again, just follow the process [I outlined in the blog post](https://nedinthecloud.com/2022/03/03/migrating-state-data-off-terraform-cloud/). It's very similar to migrating to a `local` backend, except now you are moving the state data to an Azure Storage Account. You will need the additional backend config data, which is produced as the file `backend.txt` during the `remote_state_setup` deployment.

