# Using GitHub OIDC with Azure AD and GitHub Actions

This is super cool. If you want to manage Azure with Terraform and GitHub actions, you need to provide credentials in GitHub secrets. I mean, that's not the only option. You can also use self-hosted runners in Azure and leverage MSI. But if you want to use the public runners, you'll need to add a service principal to the GitHub Secrets.

## Static Credentials in GitHub Secrets

There are multiple issues with adding static credentials to GitHub secrets. For starters, you either have to set the credentials to never expire or manually update them on a regular basis. Second, if you suspect the credentials have been leaked, you'll need to invalidate them and then reset the GitHub Secrets manually. It would be better to have short lived credentials that are generated dynamically from a trusted source, enter OIDC integration between Azure and GitHub Actions.

## OIDC with GitHub Actions and Azure AD

Basically, Azure AD is trusting that requests coming from a specific source address in GitHub are legitimate and generating credentials based on a specific Service Principal in Azure AD. If you want to see the actual process, check out the docs here. The TL;DR is that you will create a Service Principal in Azure AD and add a special set of application properties that links the SP to one of the following entities in a GitHub repository: Environment, Branch, Pull Request, or Tag.

When a GitHub Action is fired based on one of those entities, the runner machine with get a GitHub token. Then using the Azure Login action, it will reach out to Azure AD and exchange the GitHub token for an Azure AD identity token. The token exchange will only be successful if entity type requesting the token matches the federated identity information associated with the service principal in Azure AD.

## Multiple Environments

Let's set up an example using multiple service principals in Azure AD, each with permissions to a different Azure subscription: Development, Staging, and Production. In GitHub we have the same three environments defined, each tracking a different branch in our GitHub repository. Each SP will have a federated identity linked to the a GitHub environment entity.

## Deployment

This directory has a setup directory containing all the things we might need for our deployment:

* Three applications and service principals in Azure AD
* GitHub secrets for three environments in a GitHub example repo
* An Azure storage account for remote state with containers for each environment
* Permissions for each SP to access the storage account and the environment specific container

### Workspaces in Terraform

We aren't going to use workspaces. Why? Well the short answer is that we don't need them. The slightly longer answer is that we are using Azure storage as a remote backend for state data. Workspaces will create a unique blob for each workspace in the same container. The narrowest permissions you can set for Azure blob access is at the container level, meaning that each SP will have full access to all the blobs in the container. The development environment SP could access the production state data. That could be... bad. So instead, we'll create a container for each environment and scope permissions on the SP to the corresponding container.

I supposed you could still use workspaces. But why? What's the benefit here? We're already using branches and environments to break things up. No need for workspaces here!
