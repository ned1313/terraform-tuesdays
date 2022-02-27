# Migrating Off Terraform Cloud

Terraform Cloud is a pretty cool service with a bunch of excellent features. But what if you decide it's just not working out? *Sorry TFC. It's not you. It's me.* How do you migrate off of Terraform Cloud and onto another platform? In particular, how do you migrate your state data off TFC to another backend? That is what I'll address in this post.

## State Data Storage

I want to start with a few Terraform basics, since this is going to factor heavily into how state data is managed and migrated. For starters, state data is the mapping between what exists in your Terraform config and what is deployed in the target environment. I've written about it extensively in my post of what happens when changes occur outside of Terraform, so I won't rehash it here.

State data needs somewhere to live. The default location is the `local` backend, creating state files in the same directory as your configuration. There are two different scenarios to consider, working with the `default` workspace only and working with multiple or a non-default workspace. Terraform OSS workspaces allow you to use the same configuration to support multiple target environments. Each workspace has its own state data, which means Terraform needs to create multiple state data files when using the `local` backend.

When you first spin up a Terraform configuration, you have a single `default` workspace. You cannot remove the `default` workspace, you don't have to deploy anything to it. Simply create a new workspace and then run your `terraform apply`. A few key questions come to mind:

1. Where does Terraform store the workspace listing?
2. How does Terraform know which workspace is currently active?
3. Where does Terraform put the data for each workspace?

Starting with the first question, assuming you're using the `local` backend, when you create a the first non-default workspace, Terraform creates the directory `terraform.tfstate.d`. Each non-default workspace gets a subdirectory inside the `terraform.tfstate.d` directory. For instance, if I have the following workspaces: default, development, and production, then I will have the following file tree.

```bash
> tree terraform.tfstate.d

terraform.tfstate.d/
├── development
└── production
```

Jumping ahead to the third question, the state data for each workspace will be stored in a `terraform.tfstate` file inside each workspace directory. You might notice the `default` workspace doesn't have a directory. It will store its state data in the file `terraform.tfstate` in the configuration directory.

When you run `terraform workspace list`, Terraform looks at the subdirectories inside `terraform.tfstate.d` and compiles a list from there, adding the `default` workspace since it won't have a directory.

For the second question, Terraform knows which workspace is currently active by writing it to the file `.terraform/environment`. Terraform will create this file when you create your first non-default workspace. The file will have a single entry, the name of the currently active workspace. Running `terraform workspace select` simply changes the entry in this file.

## Alright! So let's deploy to Terraform Cloud.

Yes, I know this is all about migrating off Terraform Cloud, but first we have to get our data on Terraform Cloud to start with. The configuration I'm going to deploy has the following `terraform` configuration block:

```terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
  #backend "azurerm" {
  #  key = "webapp"
  #}

  cloud {
      organization = "ned-in-the-cloud"
      workspaces {
          name = "tfc-migration-test"
      }
  }
}
```

You might notice the `azurerm` backend config commented out. We'll eventually try and get our config migrated to an Azure Storage Account, but first we'll look into how to migrate to a `local` backend.

After we've run a `terraform init` and `terraform apply` our local directory does not have a `terraform.tfstate` file or `terraform.tfstate.d` directory. That's because we're using the cloud backend.  However, in the `.terraform` directory we have an environment file and a `terraform.tfstate` file. What's in those files?

The `environment` file serves the same function as before, it has a single entry identifying the currently selected workspace. The `terraform.tfstate` file holds information about the `cloud` backend:

```json
{
    "version": 3,
    "serial": 1,
    "lineage": "8e0c46e8-ef07-a6f3-1558-08d5bba7d574",
    "backend": {
        "type": "cloud",
        "config": {
            "hostname": null,
            "organization": "ned-in-the-cloud",
            "token": null,
            "workspaces": {
                "name": "tfc-migration-test",
                "tags": null
            }
        },
        "hash": 4214871454
    },
    "modules": [
        {
            "path": [
                "root"
            ],
            "outputs": {},
            "resources": {},
            "depends_on": []
        }
    ]
}

```

The actual state data is securely stored in the Terraform Cloud workspace. We can grab that state data by going to the UI or by running `terraform state pull`. 

## Migrating to the Local Backend

If you were going to migrate your state between any other two backends, the process would generally be:

1. Update the Terraform configuration with the new backend
1. Run `terraform init` to update the backend and migrate state data

But, as of right now, Terraform Cloud doesn't work that way. If we comment out the `cloud` block from our configuration and run `terraform init` we will get the following error:

```bash
> terraform init

Initializing the backend...
Migrating from Terraform Cloud to local state.
╷
│ Error: Migrating state from Terraform Cloud to another backend is not yet implemented.
│
│ Please use the API to do this: https://www.terraform.io/docs/cloud/api/state-versions.html
│
│
╵
```
*Ouch.*

That's okay! We can figure this out with all the knowledge we've already gained. The first thing I want to point out is that Terraform Cloud is apparently magic? If you run `terraform workspace list`, you'll discover that there is no `default` workspace. That's... not supposed to be allowed.

```bash
> terraform workspace list
* tfc-migration-test
```

But okay. So what do we need in place locally to support our `tfc-migration-test` workspace with the `local` backend?

* A `terraform.tfstate.d` directory with a `tfc-migration-test` subdirectory
* Our state data in a `terraform.tfstate` file in the `tfc-migration-test` directory
* Remove the `terraform.tfstate` file in the `.terraform` directory that points at the cloud config
* Update the configuration to remove the `cloud` block
* Run `terraform init` to prepare local files

That should do it! 

```bash
> mkdir -p terraform.tfstate.d/tfc-migration-test

> terraform state pull > terraform.tfstate.d/tfc-migration-test/terraform.tfstate

> mv .terraform/terraform.tfstate .terraform/terraform.tfstate.old

# Remove the cloud block in the config

> terraform init

```

Sure enough, if we make a change to the configuration, a plan will run successfully. This works well enough for a single workspace. If you have multiple workspaces, you'll need to create a directory for each workspace and pull the state data for that workspace.

## Migrating to an AzureRM Storage Account

Will the migration process be any easier if we're moving to another remote backend instead of the `local` backend? 

```bash
> terraform init -backend-config="backend.txt"

Initializing the backend...
Migrating from Terraform Cloud to backend "azurerm".
╷
│ Error: Migrating state from Terraform Cloud to another backend is not yet implemented.
│
│ Please use the API to do this: https://www.terraform.io/docs/cloud/api/state-versions.html
│
│
╵
```

*No. No, it will not.*

We should be able to follow the same basic process, only this time we need to create the necessary files in the target storage account. The container being used in Azure is `terraform-state`. The `key` value is `webapp`. The `azurerm` backend will add `env:` and the workspace name to the end `key` value. So our state file will be `webappenv:tfc-migration-test`. The migration process will be similar to the `local` migration:

* Copy our state data to `webappenv:tfc-migration-test` in the storage account container
* Remove the `terraform.tfstate` file in the `.terraform` directory that points at the cloud config
* Update the configuration to remove the `cloud` block and add the `azurerm` block
* Run `terraform init` to download files and validate config

We can grab the state data with the same `terraform state pull` command we used before. And then use the Azure CLI to copy it to our storage account.

```bash
> terraform state pull > statedata

> az storage copy -s statedata --destination-account-name tfc40300 --destination-container terraform-state --destination-blob "webappenv:tfc-migration-test"
```

Now we'll update the backend configuration, rename the `terraform.tfstate` file, and run a `terraform init`.

```bash
> mv .terraform/terraform.tfstate .terraform/terraform.tfstate.old

# Remove the cloud block in the config

> terraform init -backend-config="backend.txt"
```

In case you're wondering, the `backend.txt` file has the following in it:

```text
storage_account_name="tfc40300"
resource_group_name="tfc-40300"
container_name="terraform-state"
```

And I have the Azure Service Principal information stored in environment variables.

## Conclusion

In this post we've seen how to migrate from Terraform Cloud to either the `local` or `azurerm` backend. The process for any other backend would be similar, except you'll need to know how it handles workspaces and the actual state file data. 

As an alternative, you could perform a two stage migration from Terraform Cloud to `local` and then from `local` to your remote backend of choice. Either way, you'll still need to pull the state data down to an intermediary location before uploading to the new remote backend.

In all likelihood, HashiCorp will update the `cloud` backend to support direct migration in the not too distant future, making this entire post moot. But until then, I hope this has helped you migrate off Terraform Cloud or at least learn a bit more about how state data and workspaces are managed by Terraform.