# GCP Remote Runner

The goal behind this Terraform deployment is to create a set of GCP remote runners for GitHub actions. We are going to use Terraform to create a project and within that project we are going to create the following:

1. A managed instance group that will function as self-hosted remote runners
1. A service account with permissions to create new projects and resources in those project
1. Associate the service account with the managed instance group
1. Create a Google storage account in the current project to hold state
1. Bootstrap the managed instance group with a GitHub organization instead of a repository
1. Verify that the runner is ready to go

## The big idea

The big idea here is a way to have a remote runner in GCP create new projects and infrastructure in GCP by using the service account associated with the runner machines. When there is a new Terraform configuration that needs to be deployed, included in the configuration will be a project creation module and a GitHub actions file. The action file will use the remote runner to create a new workspace based on the release tag of the repository, then it will create the a new project and deploy the resources in the project. State will be stored in the runner project in the Google storage account.

The runner project will be handled separately from the projects it supports. We can store the state in a separate Google storage account or use Terraform Cloud to handle it for us.

## Running this sucker

You're going to need the following variable values to feed into the Terraform configuration:

* `billing_account` - The billing account number you're using in your organization.
* `org_id` - The organziation ID you're using for the deployment of this project.
* `gh_org_name` - The name of the GitHub organization you're using. (Not the display name!)
* `gh_org_url` - The URL for your organization. Should follow the format https://github.com/{org_name}.
* `gh_token` - A token value from GitHub with permissions to create runner tokens.

Of the five values, the `gh_token` is the most sensitive, so I would store that in an environment variable. The others could go in a `tfvars` file if you'd like.

Here's how to get the GCP values:

```bash
export TF_VAR_org_id=$(gcloud organizations list --format=json | jq .[0].name -r | cut -d'/' -f2)
export TF_VAR_billing_account=$(gcloud beta billing accounts list --format=json | jq .[0].name -r | cut -d'/' -f2)
```

For the GitHub org info, you'll just have to check and see what your org name is. If you don't have an org on GitHub, you can create one for free!

```bash
export TF_VAR_gh_org_name=ORG_NAME
export TF_VAR_gh_org_url=https://github.com/${TF_VAR_gh_org_name}
```

The token can be generated from your GitHub profile under Developer settings -> Personal access tokens. The token must have `admin:org` scope to use the runner token generation endpoint.

```bash
export TF_VAR_gh_token=TOKEN_VALUE
```

Once you have all your variable values set, standard Terraform workflow applies:

```bash
terraform init
terraform apply -auto-approve
```

Voila! Now you have GCP instances waiting to accept GitHub actions jobs. In the next installment, we are going to put those suckers to work!