# Workspace Options with Terraform Cloud

Terraform 1.1 brings with it some new cool Terraform Cloud management options. Cloud blocks, Tags, and Workspace commands Oh MY! But wait. What was broken about the old system? And why is this better? Let's dig in.

## Terraform Cloud Workspaces

> Everything in here is about the CLI workflow for a Terraform Cloud workspace. If you're using the VCS or API workflow, you can safely ignore most of this post. The only major improvement for you is the proper evaluation of `terraform.workspace`.

### Terraform Remote Backend

Before Terraform 1.1, the way you connected a Terraform configuration to Terraform Cloud in a CLI workflow was through the use of the `backend` block in a `terraform` configuration block. The `backend` type was `remote` and it came with settings for the `hostname`, `organization`, and `workspaces`. 

The `workspace` block had two possible arguments:

* **`name`**: associated the configuration with a single workspace in TFC with a matching name.
* **`prefix`**: matched your current local workspace to a workspace in TFC by adding a prefix.

The two arguments are mutually exclusive. You might be wondering about the `prefix`, so allow me to illustrate with an example:

```terraform
terraform {
    backend "remote" {
        hostname = "app.terraform.io"
        organization = "taconet"
        workspaces {
            prefix = "networking-"
        }
    }
}
```

When you initialize the configuration, it will look for any workspaces in the target organization that have the prefix "networking-". The next action will depend on what it finds:

* **No matching workspace**: Terraform will prompt you to create one using the `terraform workspace` command.
* **One matching workspace**: Terraform will automatically select the workspace for you.
* **Multiple matching workspaces**: Terraform will prompt you to select a workspace from the list.

Since we are starting with an empty organization, there will be no matching workspaces. The following command will create a workspace:

```bash
terraform workspace new dev
```

Listing out the workspaces at the CLI will show the following:

```bash
$ terraform workspace list

* dev

```

Looking at the workspaces on Terraform Cloud, you'll see a workspace called `networking-dev`. Terraform is adding the prefix for the workspace it generated in Terraform Cloud.

The main problem with the `prefix` argument is the cognitive dissonance between what you're seeing at the command line - a workspace called `dev`, and in Terraform Cloud - a workspace called `networking-dev`. This is further compounded by a problem with the `terraform.workspace` value.

Before Terraform 1.1, the workspace used by the remote runner was **always** the `default` workspace. If you used the `terraform.workspace` value in your code, it would evaluate to `default` no matter what the name of the workspace was locally or in Terraform Cloud. 

Terraform 1.1 set out to fix this and add room for future capabilities.

### Terraform Cloud Block

Terraform 1.1 introduced the `cloud` block as an alternative to `backend "remote"`. The arguments were mostly the same including `hostname` and `organization`. The main change was with the `workspaces` block, which now had the `name` and `tags` arguments.

* **`name`**: associated the configuration with a single workspace in TFC with a matching name.
* **`tags`**: match your current local workspaces to workspaces with matching tags.

One of the goals behind the `cloud` block was to remove the cognitive dissonance between local workspaces and Terraform Cloud workspaces.

How did it do that? By giving you full control over naming each workspace, but at the same time applying consistent metadata tags to each workspace associated with a configuration. An example would be helpful.

```terraform 
terraform {
    cloud {
        organization = "taconet"

        workspaces {
            tags = ["cloud:aws", "security"]
        }
    }
}
```

When you initialize the configuration, Terraform will look for any workspaces in the target organization that have the tags "cloud:aws" and "security". The next action will depend on what it finds:

* **No matching workspace**: Terraform will prompt you to create one directly.
* **One matching workspace**: Terraform will automatically select the workspace for you.
* **Multiple matching workspaces**: Terraform will prompt you to select a workspace from the list.

You might notice that instead of asking you to creating a workspace using the `terraform workspace new` command, the dialog prompts you to do so as part of the workflow. That's a small, but appreciated improvement to the experience. 

Let's say I created a workspace called `shared-services-dev` during initialization. Running the `terraform workspace list` command would show me the following:

```bash
$ terraform workspace list

* shared-services-dev

```

Looking at the workspaces on Terraform Cloud, I will see a workspace named `shared-services-dev` with the tags "cloud:aws" and "security". The dissonance between my local workspaces and what I see in Terraform Cloud is gone. 

Even better, regardless of which workflow you use, Terraform 1.1 will use the actual workspace name on the remote runner. That means the `terraform.workspace` value will evaluate properly again.

## Migrating from Backend Remote to Cloud

What if you've gone all in on using the `backend "remote"` method to manage your workspaces and now you want to move to the `cloud` block? Whether you are using the `name` or `prefix` argument in your backend block, the migration process is essentially the same.

If you've been using the `prefix` argument, then you will need to decide on tags to apply to the migrating workspace. For the `name` argument, you can simply use the same value for the `name` argument in the `cloud` block.

Let's look at an example of the `prefix` scenario. We've got three workspaces in Terraform Cloud: `application-dev`, `application-staging`, and `application-prod`. The current `backend` block looks like this:

```terraform
terraform {
    backend "remote" {
        hostname = "app.terraform.io"
        organization = "taconet"
        workspaces {
            prefix = "application-"
        }
    }
}
```

And a workspace listing on your local workstation would show the following:

```bash
$ terraform workspace list

  dev
* prod
  staging

```

The first thing to remember is that all the state data and workspace information is stored up in Terraform Cloud. The workspaces you have on your local workstation **do not matter**. What you're trying to do is map to the Terraform Cloud workspaces using the new `cloud` block. Since we have multiple workspaces using the same configuration, we are going to use the `tags` argument.

 Let's say we want to use the tag "app:taco" to identify our migrated workspaces. We can update our configuration replacing the `backend` block with the `cloud` block:

```terraform
terraform {
    cloud {
        organization = "taconet"

        workspaces {
            tags = ["app:taco"]
        }
    }
}
```

Because we are changing our backend, we need to run `terraform init`. You might think you need to go into Terraform Cloud and add the "app:taco" tag to the three workspaces, but you don't! When you run `terraform init`, Terraform will recognize you are migrating from the `remote` backend to the `cloud` backend. Stored in the local state file is the following information:

```json
"backend": {
        "type": "remote",
        "config": {
            "hostname": "app.terraform.io",
            "organization": "taconet",
            "token": null,
            "workspaces": {
                "name": null,
                "prefix": "application-"
            }
        },
        "hash": 1338747517
    }
```

During the migration process, Terraform will use the prefix information stored in local state and your existing list of local workspaces to find the matching workspaces in Terraform Cloud. Then it will apply the `tags` list in the `cloud` block and migrate the state. It will also update your local workspace names to match the names in Terraform Cloud.

One important caveat! If you have a bunch of existing workspaces in Terraform Cloud, chances are they are set to use an older version of Terraform. The `cloud` block and migration functionality **requires** that your Terraform Cloud workspace is at Terraform v1.1 or higher. Before you run the migration, go into each impacted workspace and update the Terraform version in the General settings. If you don't, you'll get this fun message:

```bash
│ Error: Error migrating the workspace "dev" from the previous "remote" backend
│ to the newly configured "cloud" backend:
│     Error loading state:
│     Remote workspace Terraform version "1.0.1" does not match local Terraform version "1.1.2"
```

Don't worry! Nothing is broken. Terraform fails gracefully on the migration. Simply go and update the workspaces to the proper Terraform version and run `terraform init` again.

Once the migration completes, you'll see that your local workspace names now match what is in Terraform Cloud, and the Terraform Cloud workspaces have the proper tags.

```bash
Migration complete! Your workspaces are as follows:
* application-dev
  application-prod
  application-staging
```

## Cloud Block Questions

HashiCorp could have introduced these improvements without creating a new configuration block type, so why did they do it? In part, I think it comes down to semantics. Terraform Cloud isn't just a backend, it's got a lot more services and features, including remote operations. Creating the `cloud` configuration block makes the difference clear and creates a migration path.

The other part is future updates and features. Instead of adding more arguments to the `backend` block that are Terraform Cloud specific, they can leave the `backend` block alone and introduce new options in the `cloud` block. What are those new options? No idea. But you can bet they're coming soon.

## Conclusion

The new `cloud` block in Terraform 1.1 provides an improved experience for those using the CLI workflow. Workspace names match between local and Terraform Cloud, and you can use tags to manage multiple workspaces. This change paves the way for future improvements in Terraform Cloud and the CLI experience. Migration from the `remote` backend is a simple affair as long as you remember to update the version of Terraform used by your workspaces.