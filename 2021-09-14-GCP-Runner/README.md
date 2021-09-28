# Self-hosted Runners for GitHub Actions on Google Cloud

The big idea here is a way to have a self-hosted runner in GCP create new projects and infrastructure in GCP by using the service account associated with the runner machines. When there is a new Terraform configuration that needs to be deployed, included in the configuration will be a project creation module and a GitHub actions file. The action file will use the self-hosted runner to create a new workspace based on the release tag of the repository, then it will create a new project and deploy the resources in the project. State will be stored in the runner project in the Google storage account.

The runner project will be handled separately from the projects it supports. We can store the state in a separate Google storage account or use Terraform Cloud to handle it for us.

## GCP Self-hosted Runner

The goal behind this Terraform deployment is to create a set of GCP self-hosted runners for GitHub actions. We are going to use Terraform to create a project and within that project we are going to create the following:

1. Google project for the self-hosted runners, storage bucket, and service account
1. Managed instance group that will function as self-hosted runners
1. Service account with permissions to create new projects
1. Google storage bucket in the runner project to hold state

## Prerequisites and commands

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

Once you have all your variable values set, standard Terraform workflow applies. You will need to authenticate to Google Cloud using the `gloud` CLI or with service account credentials. If you want to use your `gcloud` CLI creds, select the configuration you would like to use and then run the following:

```bash
gcloud auth application-default login
```

The credentials you use for Google Cloud should have rights at the organization level to create projects, assign roles, and query billing information.

Now you can run the standard Terraform workflow.

```bash
terraform init
terraform apply -auto-approve
```

Voila! Now you have GCP instances waiting to accept GitHub actions jobs. If you go into the Runner settings in your GitHub organization, you should see two runner sitting idle. The output of the Terraform configuration will include the bucket name. In the next installment, we are going to put those self-hosted runners to work!