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

## Phase One

