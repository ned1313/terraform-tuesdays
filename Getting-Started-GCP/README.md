# Getting Started with GCP

In this video we are going to get started with using Terraform on GCP. The idea is to build something fairly simple in GCP and touch on some of the aspects of the provider and resources within. Out of the big three, I find the GCP provider the hardest to use. There are two primary reasons for this: 1. The APIs 2. The authentication.

That being said, I'll try to address each of those in turn with a few examples.

I'm also going to assume that you are somewhat familiar with GCP. This isn't an intro to GCP. At a minimum, you should know that GCP uses projects as it's primary organizing principle. Resources are associated with projects in a similar way that resources in Azure are members of a resource group. Projects are also a way to organize and delegate permissions in a hierarchical format and associate a billing account to the resources in the project.

## The Provider

Let's start with the least intuitive portion of the Google provider: there are **two** providers. The first one is the regular `google` provider and the other is the `google-beta` provider. If you want to use a feature that is currently in *beta*, you will need to explicitly define a `google-beta` provider block and reference the provider in the resource or data source. Was there a better way to handle this? Yes, absolutely. Did Google do it the hard way? Well, this is Google we're talking about here.

Both providers take the same arguments, so at least you can define everything in variables and repeat your provider block.

```terraform
provider "google" {
    project = var.project_id
    region  = var.region
    zone    = var.zone
}

provider "google-beta" {
    project = var.project_id
    region  = var.region
    zone    = var.zone
}
```

## Authentication

Just like the AWS and Azure providers, there are multiple ways to authenticate to GCP. It really breaks down into three categories:

* CLI based login
* Identity based login
* File based login

Let's break those three options down a bit.

### CLI based login

You can authenticate using the identity associated with the Google Cloud SDK (aka gcloud CLI). Once you authenticate with the command `gcloud auth application-default login`, those credentials are cached locally. Terraform can find those creds and use them. This is similar to using `az login` or `aws configure` to set local credentials. It is also the preferred way to authenticate on your local workstation.

### Identity based login

If you are running Terraform from GCP, then you can take advantage of the account associated with the resource running Terraform. This is similar to an EC2 instance identity or Azure MSI. The *machine* has an identity and you can grant that identity permissions. Terraform will automatically discover the machine identity and use it, unless you override the provider authentication with a different form.

### File based login

Finally, you can authenticate using a service account key, which is a JSON file. You can pass the file location or the contents of that file directly to the provider using the `credentials` argument, or you can set the path or contents using one of three environment variables: `GOOGLE_CREDENTIALS`, `GOOGLE_CLOUD_KEYFILE_JSON`, `GCLOUD_KEYFILE_JSON`.

Why three different environment variables? Good question! Next question please. 

Just kidding! As far as I can tell, there is no difference between the three. Each is probably maintained for some backward compatibility thing. Personally, I would use `GOOGLE_CREDENTIALS` since it's the shortest and easiest for me to remember. YMMV.

## Enabling APIs

Another thing you might not be used to dealing with in other clouds is enabling APIs. Again, this is Google, so everything is harder in the name of "simplicity". Each service you want to use in your project has an API associated with it. You must enable the API before you can use the data sources or resources in that service. It would be nice if the docs for each resource/data source told you which API you needed to enable, but that appears to be a bridge too far.

Fortunately, if the credentials you are using for your project have the proper permissions, you can enable APIs in your Terraform configuration directly. That might be overly permissive in your org, so check with internal best practices first. The syntax looks like this:

```terraform
resource "google_project_service" "service" {
  for_each = toset([
    "compute.googleapis.com",
    "appengine.googleapis.com",
    "appengineflex.googleapis.com",
    "cloudbuild.googleapis.com"

  ])

  service = each.key

  project            = google_project.project.project_id
  disable_on_destroy = false
}
```

There's many options here. You could create the project in your Terraform configuration, enable the proper APIs, and then create the necessary resources. You could have a separate Terraform configuration that creates projects for you and gives you a project ID with the proper APIs already enabled. Or you could have a manual process that creates projects, assigns permissions, and enables the proper APIs. I guess it all depends on your organization's preference.

## Example One

Let's start really simple by creating a compute instance in an existing project with our local credentials. To do this, we'll first need to login into GCP and create a project to use. You will need a GCP account and the Google Cloud SDK installed locally. You can install the SDK by following the directions [here](https://cloud.google.com/sdk/docs/install).

Once you've installed the SDK, go ahead and run the following command to log in:

```bash
gcloud init
```

You're going to be prompted to log in. Select Y to login. Then you'll be provided with a link and hopefully a new browser window to log in from. In the browser window, select the Google account associated with your GCP account. Grant the Google Cloud SDK the permissions to access your account. 

Back at the command line, you'll be prompted to select a project or create a new one. Select an existing project, we'll create a new one shortly. The configuration is saved as `default`. If you haven't created a billing account, you'll need to do that now from the portal. Once we have a project created, we need to associate it with a billing account before we can spin up resources.

Now we'll create our new project and set Terraform up to use our current login:

```bash
PROJECT_ID=taconet-${RANDOM}
gcloud projects create $PROJECT_ID --set-as-default

gcloud auth application-default login
```

Once the project is created, we need to associate billing info with our new project. You'll need to either install the alpha commands for the Google Cloud SDK, or go to the console. If you're doing it through the console:

* Go into the cloud console
* Go into billing -> Account Management
* Select the My Projects tab
* Click on the Actions button for the new project and Change Billing
* Select the proper billing account and save the change

You'd think that's it, but wait there's more. **BEFORE** we use Terraform, we need to enable the Compute Engine service API.

```bash
gcloud services enable compute.googleapis.com
```
 
Finally, we get to do some Terraform stuff. From the `ExampleOne` directory, run the following:

```bash
terraform init

terraform validate

terraform plan -var gcp_project=${PROJECT_ID} -out ex1.tfplan

terraform apply ex1.tfplan
```

This will deploy a Compute Engine instance with a public IP address and Apache installed. We can verify by going to the address shown in the Terraform output. It may take up to 5 minutes for Apache to install after the instance is available.

Once you're done, you can clean up by running the following:

```bash
terraform destroy -var gcp_project=${PROJECT_ID} -auto-approve

gcloud projects delete ${PROJECT_ID} --quiet
```

## Example Two

Next, we're going to authenticate using a service account key and use Terraform Cloud to run the configuration. The configuration will create a project based on a prefix name, enable some services, and return the project-id as output. We're first going to need to set up a service account key with the proper permissions and then add the contents of the service key as an environment variable in Terraform Cloud.

You'll need to have a GCP organization to follow along with this one. If you don't already have an organization set up, it's not terribly difficult to do. Follow along with the directions [here](https://cloud.google.com/resource-manager/docs/creating-managing-organization#setting-up). The account you're using will need permissions to make organization level changes. Assuming you're the one setting all this up, you probably already have the necessary permissions.

The next set of directions are based heavily on [this tutorial](https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform) from GCP. You should already be logged in with to the Google Cloud SDK with an account that has the necessary permissions in your organization. Next we'll get the organization id and billing account to use for the Terraform configuration and other commands.

In both commands, we are selecting the first result from the list of organizations and billing accounts. If you have multiple of either, you may need to tweak the commands to find the proper result.

```bash
ORG_ID=$(gcloud organizations list --format=json | jq .[0].name -r | cut -d'/' -f2)
BILLING_ACCOUNT=$(gcloud beta billing accounts list --format=json | jq .[0].name -r | cut -d'/' -f2)
```

Next up, we'll create an admin project to hold all the resources used to manage a project separate from the created projects. We'll call this project `terraform-admin-#####`.

```bash
PROJECT_ID="terraform-admin-${RANDOM}"

gcloud projects create ${PROJECT_ID} \
  --organization ${ORG_ID} \
  --set-as-default

gcloud beta billing projects link ${PROJECT_ID} \
  --billing-account ${BILLING_ACCOUNT}
```

Now we are going to create the service account that Terraform Cloud will use to create new project. We're going to download the service account key file, and later copy it into an environment variable in our Terraform Cloud configuration. We're also giving the service account the necessary permissions in the organization and project.

```bash
gcloud iam service-accounts create terraform \
  --display-name "Terraform Cloud account"

gcloud iam service-accounts keys create ~/${PROJECT_ID}-key.json \
  --iam-account terraform@${PROJECT_ID}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/billing.user

```

And finally we'll enable some APIs, because that's how things work in GCP:

```bash
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable serviceusage.googleapis.com
```

Now in Terraform Cloud, go ahead and create a Workspace called `gcp-getting-started` that uses a CLI-driven workflow. Then create the following variables in the workspace:

* `billing_account`
* `org_id`

Use the values stored in `$ORG_ID` and `$BILLING_ACCOUNT` and set the values as sensitive.

```bash
echo $BILLING_ACCOUNT
echo $ORG_ID
```

Next we will set the environment variable for the GCP credentials. Copy the contents of the the service account key file:

```bash
jq . -c ~/${PROJECT_ID}-key.json
```

And create an environment variable named `GOOGLE_CREDENTIALS` with the value set as sensitive. If you get an error that there are newlines, paste the string into an editor and see where the newline is.

Now we should be ready to create a project using Terraform. From the `ExampleTwo` directory, run the following.

```bash
# If you aren't logged into Terraform Cloud
terraform login

terraform init

terraform apply -auto-approve
```

The output from the run will be the project ID. You could now use this project to create resources!

You can clean things up by destroying the Terraform config, deleting the workspace, and deleting the admin project in GCP:

```bash
terraform destroy -auto-approve

gcloud projects delete ${PROJECT_ID} --quiet

rm ~/${PROJECT_ID}-key.json
```