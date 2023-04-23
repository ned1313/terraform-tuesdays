# Simple OIDC Example

The following example shows how to configure a simple OIDC setup with Azure AD as the identity provider. The example uses the following components:

* GitHub repo with sample code
  * Repo to fork is [here](TODO: add link)
* Azure AD tenant and subscription
  * You will need access to create a service principal and assign Contributor role in the subscription

You will use the Azure CLI to authenticate and a GitHub PAT to access the repo. 

## Running the Config

You will set the following environment and Terraform variables:

* repository_name - the name of the repository to add the secrets to
* GITHUB_TOKEN - the GitHub PAT to access the repo and add the secrets

For the Azure components, you should log into Azure and select a subscription:

```bash
az login
az account set -s SUBSCRIPTION_NAME
```

Then run the standard Terraform commands:

```bash
terraform init
terraform apply
```
