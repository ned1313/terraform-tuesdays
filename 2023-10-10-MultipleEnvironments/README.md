# Managing Multiple Environments

There are three subfolders in this example that can help you test out different environments:

1. `branch_setup`
2. `folder_setup`
3. `repo_setup`

Each directory contains a Terraform configuration to complement the environment management examples.

## Branch Setup

The Branch setup will deploy the following resources:

* An Azure AD application, service principal, and federated identities for the different environments
* An Azure storage account and container for the Terraform state with permissions granted to the Azure AD service principal
* An Azure role assignment granting the Azure AD service principal the ability to manage resources in the current subscription
* GitHub Actions Secrets for the repository you'll use for the example

Before you run the setup configuration, you should [fork the linked repository](https://github.com/ned1313/tt-branch-example/), including all branches. That will be the repository you'll use to try out using multiple branches. The repo has four branches: main, dev, prod, and staging. The dev, prod, and staging will be used to deploy resources in Azure. Main is the source of truth for current and future environments.

After you fork the repository, create a GitHub personal access token with permissions to work with repositories and workflows. You're going to store the PAT as an environment variable called `GITHUB_TOKEN`. Terraform will use that to create the GitHub Actions secrets.

In the `terraform.tfvars` file update the repository name to your fork, and leave the environments alone for now. Then run the standard terraform commands to deploy the resources.

Once you're done, you can walk through the instructions included in the `README.md` for the example repository.