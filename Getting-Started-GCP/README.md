# Getting Started with GCP

In this video we are going to get started with using Terraform on GCP. The idea is to build something fairly simple in GCP and touch on some of the aspects of the provider and resources within. Out of the big three, I find the GCP provider the hardest to use. There are two primary reasons for this: 1. The API 2. The authentication.

That being said, I'll try to address each of those in turn with a few examples.

I'm also going to assume that you are somewhat familiar with GCP. This isn't an intro to GCP. At a minimum, you should know that GCP uses projects as it's primary organizing principle. Resources and associated with projects in a similar way that resources in Azure are members of a resource group. Projects are also a way to organize and delegate permissions in a hierarchical format.

## The Provider

Let's start with the least intuitive portion of the Google provider: there are two providers. The first one is the regular `google` provider and the other is the `google-beta` provider. If you want to use a feature that is currently in *beta*, you will need to explicitly define a `google-beta` provider block and reference the provider in the resource or data source. Was there a better way to handle this? Yes, absolutely. Did Google do it the hard way? Well, this is Google we're talking about here.

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

You can authenticate using the identity associated with the Google Cloud SDK (aka gcloud CLI). Once you authenticate with the command `gcloud auth application-default login`, those credentials are cached locally. Terraform can find those creds and use them. This is similar to use `az login` or `aws configure` to set local credentials. It is also the preferred way to authenticate on your local workstation.

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

There's many options here. You could create the project in your Terraform configuration, enable the proper APIs, and then create the necessary resources. You could have a separate Terraform configuration that creates projects for you and gives you a project ID with the proper APIs already enabled. Or you could have a manual process that creates projects, assigns permissions, and enables the proper APIs. I guess it all depends on your preferred process.

## Example One

Let's start really simple by creating a compute instance in an existing project with our local credentials. To do this, we'll first need to login into GCP and create a project to use. In the `ExampleOne` directory, I have listed out the commands necessary to do this. You will need to already have a GCP account and some billing information associated with the account.

## Example Two

Next, we're going to authenticate using a service account key and Terraform Cloud to run the configuration. The configuration will create a project based on the workspace name, enable some services, and return the project-id as output. We're first going to need to set up a service account key with the proper permissions and then add the contents of the service key as a multiline variable in Terraform Cloud.

You'll need to have a GCP organization to follow along with this one. If you don't already have an organization set up, it's not terribly difficult to do. Follow along with the directions [here](https://cloud.google.com/resource-manager/docs/creating-managing-organization#setting-up). The account you're using will need permissions to make organization level changes. Assuming you're the one setting all this up, you probably already have the necessary permissions.

The next set of directions are based heavily on [this tutorial](https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform) from GCP. You should already be logged in with to the Google Cloud SDK with an account that has the necessary permissions in your organization. Next we'll get the organization id and billing account to use for this enterprise.

>Note: I am going to use bash for this portion. Apologies to Windows users, it's just easier.

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

Now we are going to create the service account that Terraform Cloud will use to create new project. We're going to download the service account key file, and later copy it into a variable in our Terraform Cloud configuration.

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

Use the values stored in `$ORG_ID` and `$BILLING_ACCOUNT` and set the value as sensitive.

```bash
echo $ORG_ID
echo $BILLING_ACCOUNT
```

Next we will set the environment variable for the GCP credentials. Copy the contents of the the service account key file:

```bash
cat ~/${PROJECT_ID}-key.json | tr '\n' ' '
```

And create an environment variable named `GOOGLE_CREDENTIALS` with the value set as sensitive.

Now we should be ready to create a project using Terraform.

