# Using Azure Container Instances as a self-hosted agent in Azure DevOps

When you create a new organization in Azure DevOps, you get are not able to run any pipeline job using the Microsoft-hosted agents. That's intensely annoying, and it stymies you ability to try out various functionalities of Azure DevOps, as well as do some of the exercises on Microsoft's Learn platform!

You have one of three options to remedy this situation:

1. You can fill out this form and wait 1-3 days for them to grant you a single parallel job for free.
1. You can pay for an Azure DevOps subscription that includes parallel jobs.
1. You can use a self-hosted agent.

This repository is meant to assist you with the third option. The contents will spin up an Azure Container Instance (ACI) that has the Azure DevOps agent installed. Through the use of environment variables, you can configure the agent to be part of one of the pools provisioned in your Azure DevOps organization.

To make things even easier, I've added an option to provision the pool in ADO for you as well.

## Prerequisites

You'll need the following:

* An Azure subscription
* An Azure DevOps organization (free tier)
* The Azure CLI installed on your machine
* A Personal Access Token (PAT) for your Azure DevOps organization
  * The token should have Full Access

By default, the configuration uses my `ned1313/azp-agent:1.2.0` image. The image is based on the `ubuntu:20.04` image and has the Azure DevOps agent installed. It also included some common tools like `curl`, `jq`, and `unzip`. Here's a link to the [image build repository](https://github.com/ned1313/azuredevops-pipeline-agent) in case you'd like to see what's included, or fork it for yourself.

On startup, the image will grab the latest version of the Azure DevOps agent for your organization and configure it to run as a service. The agent will be added to the pool you specify in the environment variables.

## Instructions

1. Clone this repository to your local machine.
1. Copy and rename the `terraform.tfvars.example` file to `terraform.tfvars`.
1. Fill in the values in the `terraform.tfvars` file.
1. Run `terraform init` to initialize the Terraform configuration.
1. Run `terraform apply` to create the ACI instance and option Azure DevOps pool.

The output of the `terraform apply` will include the pool name. You can use this to configure your pipeline jobs to use this pool.

If you choose to let the configuration create a pool for you, it will be available to all projects in your Azure DevOps organization. However, you will still need to grant each pipeline job permission to use the pool.

## Cost

ACI is not free, but it is relatively inexpensive. If you want totally free, spin the image up on your local workstation instead. The cost of an ACI group varies by region, so I recommend consulting the [Azure pricing page](https://azure.microsoft.com/en-us/pricing/details/container-instances/#pricing) for the most up-to-date information. The configuration uses 1 vCPU and 2 GB of memory, which if you run it for an hour in US East would come out to about $0.05 or $1.20 per day. You might be able to save a little money by using less vCPU or memory, but I haven't tested that.

You can also destroy the ACI instance when you're not using it and leave the pool in place. The pool doesn't cost anything to maintain.
