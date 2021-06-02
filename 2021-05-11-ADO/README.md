# Azure DevOps

This is the beginning of a multi-part series looking into deploying Terraform using Azure DevOps. There are several goals I want to accomplish in this project.

1. Create a pipeline in Azure DevOps using YAML
1. Validate the Terraform code as part of the pipeline (validate and format)
1. Move credentials and sensitive data into Azure Key Vault
1. Use Azure Storage for remote backend with credentials in Key Vault
1. Generate a plan for the Terraform code
1. Stash the plan in an Azure Storage account
1. Validate the plan with a manual step
1. Deploy the code once the manual step is approved
1. Separate the pipeline into two pipelines, one for PR and one for merge
1. Add code scanning to the process using Checkov
1. Add testing to the process using terratest or Module Testing

Admittedly, that's a lot of stuff for a pipeline, but we don't have to do everything all at once. In the first phase, I simply want to get a basic pipeline working and creating an Azure Vnet. This will require remote state for consistency, so that should be there from the get-go. I also would really like to use Azure Key Vault for credential storage.

## Setup

Before I set up the pipeline, I'm going to need an Azure Storage Account and Azure Key Vault. I'm also going to need to configure the pipeline with access to the Key Vault. Not sure if I can do that through Terraform or if I'll need to do it after the fact. Within ADO, I'm going to need a project for the pipeline to live in, and that project will need to be wired to a GitHub repo where my code is stored. Not sure if I can do any of that with Terraform, but I'll check it out. The results will be in the setup folder in this directory.

*An indeterminate amount of time later*

Okay, it looks like I can create a project, GitHub service connection, and pipeline all through Terraform. Excellent! If you're following along, you'll notice I'm using the Terraform Cloud backend. You're going to need to set some variables and environment variables for your workspace to make it all hum. I'll list those out below.

### Terraform Cloud Variables

Here is a list of variables and values you'll need to specify for the config to work:

**Terraform Variables**

* `ado_org_service_url` - Org service url for Azure DevOps
* `ado_github_repo` - Name of the repository in the format `<GitHub Org>/<RepoName>`. You'll need to fork my repo and use your own.
* `ado_github_pat` (**sensitive**) - Personal authentication token for GitHub repo.


**Environment Variables**

* `AZDO_PERSONAL_ACCESS_TOKEN` (**sensitive**) - Personal authentication token for Azure DevOps. 
* `ARM_SUBSCRIPTION_ID` - Subscription ID where you will create the Azure Storage Account.
* `ARM_CLIENT_ID` (**sensitive**) - Client ID of service principal with the necessary rights in the referenced subscription.
* `ARM_CLIENT_SECRET` (**sensitive**) - Secret associated with the Client ID.
* `ARM_TENANT_ID` - Azure AD tenant where the Client ID is located.
* `TF_VAR_az_client_id` (**sensitive**) - Client ID of service principal that will be used in the Azure DevOps pipeline.
* `TF_VAR_az_client_secret` (**sensitive**) - Client secret of service principal that will be used in the Azure DevOps pipeline.
* `TF_VAR_az_subscription` - Subscription ID where resources will be created by the ADO pipeline.
* `TF_VAR_az_tenant` - Tenant ID for the `az_client_id` value.

You can decide if you want to mark anything else as **sensitive**. The client id might not really need to be sensitive, but that's what I decided to do. I went with environment variables for a bunch of these, but the long term plan is to dynamically create the necessary service principals and store the information in Key Vault.

## Phase One

The whole purpose behind phase one is to get the basic framework in place for an Azure DevOps pipeline. You might look at this setup and think that it is too simple or is missing out on using a bunch of features. You're right! It is intentionally simple for phase one, and I plan to add complexity as we go. Right now the set up script is creating the following:

* Azure storage account for remote state
* SAS token for storage account access
* Azure DevOps project
* Service endpoint to GitHub repo for ADO
* Variable group for pipeline to use
* Build pipeline

The pipeline itself is deploying a simple Azure virtual network with two subnets. Nothing fancy. The stages validate the Terraform code, run a plan, wait for approval, and run an apply. That's it. The trigger is a commit to the 2021-05-11-ADO/vnet directory. That will change eventually.