# Managing Terraform Cloud with the TFE Provider

Terraform Cloud is a hosted service from HashiCorp that expands on the capabilities of Terraform OSS, including a graphical UI, managed state data location, team based access control, and integrations with other products. There are a few core constructs to understand when it comes to how TFC is managed and organized:

* **Organizations** - the core management unit for your Terraform configurations. 
* **Workspaces** - exist within an organization and associated with a single Terraform deployment.
* **Teams** - used to grant permissions at the organization and workspace levels. Each 
* **TFC Accounts** - accounts in Terraform Cloud that can be members of one or more organizations.
* **Users** - link between a TFC account and an organization. Must be a member of at least one team in an organization.

The central management unit in TFC is the organization. It contains the workspaces, teams, users, Sentinel policies, and variable sets. When you sign up for a TFC account, you have the option to create an organization through the UI. From there you can create all the other resources I just mentioned, like teams and workspaces. 

## Using Terraform on TFC

When you're just getting started, building out TFC by hand in the UI is fine. No big deal. But just like anything else in the world of Terraform, it's better if you can shift to defining things declaratively. Naturally, there is a a `tfe` provider available to configure both Terraform Cloud and Terraform Enterprise using Terraform. 

There are several benefits to using Terraform to configure TFC:

* Consistency - It's easier to make sure teams are assigned access consistently when you are pushing the changes from an external source.
* Efficiency - Making the same change across 10 workspaces is much easier when you're doing it programmatically.
* Transparency - All changes made to the organization will be documented in the code changes. You can compare audited changes to your Git log.

Basically, if you plan on running TFC at scale with tens or hundreds of workspaces, trying to manage through the UI will be a nightmare. So we are going to use Terraform and IaC to manage TFC.

But that begs a few questions. 

1. Where does the Terraform code run to configure your organization?
1. Where do you store the configuration about your TFC organization?
1. How many organizations should you be running?

### Where to run the code?

The answer to the first question could simply be running Terraform OSS on your local desktop, but that's no fun. You have TFC there just begging to be used. So what I would suggest is to have dedicated organization for configuring other organizations running in TFC. We'll call it a Configuration Organization (CO). Access to the CO should be tightly controlled, and each org it manages should have its own workspace. The best part is that due to the limited nature of the CO, you can stay on the free tier of billing. It includes everything you'll need. Unless of course you want to create teams and grant special access within the CO, but like I said, you should keep access to the CO down to just a few people. Like... five maybe?

### Where to store the configuration?

Probably the best place to store the configuration data and code is in a private repository on VCS system. All changes and updates can be pushed through a standard GitOps process. TFC includes a VCS workflow that can be tied back to your VCS repositories. When a commit is made to a tracked branch, that can kick off a run on TFC to apply the change to the target organization. The VCS workflow also supports tracking a specific directory in the repository, so you could have all your organizations managed from a single repository or have one organization per repository. The choice is yours.

### How many organizations?

Chances are that even the biggest enterprises won't need more than one or two organizations. There is effectively no limit on how many workspaces and teams you can have in an organization. There are three probable reasons for multiple organizations in a company:

1. You are running an MSP for TFC and each client gets their own dedicated organization.
1. Billing is done per organization, and you have internal business units that want dedicated licenses for users.
1. Business units in your company want to administer their own organization for "reasons".

It's unlikely you're going to have hundreds of organizations at your company. But you may have a handful. The more important resources to worry about are workspaces and teams. That is what we want to manage programmatically.

## Using Terraform and the TFE Provider

The TFE (Terraform Enterprise) provider in the public Terraform Registry is able to configure many aspects of a TFC organization, including workspaces and teams. However, you still need to put the pieces together yourself. And that's why I decided to write a module for managing an organization. The primary idea is that the module should be able to create the following:

* Workspaces with options set for tags, Terraform version, and team access
* Teams with membership and organization level permissions
* Users associated with teams

My first idea was to craft some complicated variable object to store all this information and apply it. That quickly became a nightmare, and I realized the best thing to do was store the data in JSON and parse it with Terraform. Here's the overall format:

```json
{
    "workspaces": [
        {
            "name": "workspace_name",
            "description": "workspace description",
            "teams": [
                {
                    "name": "team_name",
                    "access_level": "access_level"
                }
            ],
            "terraform_version": "1.1.0",
            "tag_names": [ "tag1" ]
        }
    ],
    "teams": [
        {
            "name": "team_name",
            "visibility": "visibility_level",
            "organization_access": {
                "manage_policies": true,
                "manage_policy_overrides": true,
                "manage_workspaces": false,
                "manage_vcs_settings": false
            },
            "members": ["user_email_address"]
        }
    ]

}
```

The list of users can be extrapolated from the list of team members, so we really only need the teams and workspaces. 

Since there's no sensitive information in the configuration data, it can be safely stored with the rest of the Terraform code. If you're worried about the user emails being stored, then you'll need to add them some other way.

With the information stored in JSON, I need to use it in Terraform. Importing JSON data is super easy with the `jsondecode` and `file` functions. Essentially the JSON is imported as a complex object, and I can use standard Terraform object reference syntax to extract information.

For instance, to get all the workspaces I simply have to do this:

```terraform
locals {
    org_data = jsondecode(file("${var.config_file_path}"))

    workspaces = local.org_data.workspaces
}
```

## Using For-Each Loops

For most of the resources I am creating I want to use `for_each` instead of `count` for my meta-argument. That's because when assigning teams to workspaces or users to teams, I need to reference the `team_id` or `workspace_id` for the target team of workspace. If I use a `count` argument, I would have to use some type of `for` expression to filter for the proper resource. When I use a `for_each` argument, I can refer to the resource by name. Is that confusing? I guess it is. Let me explain in more detail.

Let's say we have the following local data:

```terraform
locals {
    list_of_objects = [
        {
            name = "John"
            team = "tacos"
        },
        {
            name = "Peggy"
            team = "burritos"
        }
    ]
}
```

And I want to loop through it in a resource. I can't use `for_each` as it is, because I have a list of objects and `for_each` only accepts a set of strings.

If I decide to use `count` instead, I can simply do the following:

```terraform
resource "fake_resource" "teams" {
    count = length(local.list_of_objects)
    name = local.list_of_objects[count.index].name
}
```

And now I'll have the following resources:

```hcl
fake.resource.teams[0] = {
    name = "John"
}

fake.resource.team[1] = {
    name = "Peggy"
}
```

I created my resources, but now I can only refer to them by index. What's the alternative? I can create a map with a for expression using a unique attribute as the key and the existing maps as the values.

```terraform
locals {
    list_of_objects = [
        {
            name = "John"
            team = "tacos"
        },
        {
            name = "Peggy"
            team = "burritos"
        }
    ]

    map_of_objects = { for entry in local.list_of_objects : entry["name"] => entry }
}
```

The new map will look like this:

```hcl
{
    John = {
        name = "John"
        team = "tacos"
    },
    Peggy = {
        name = "Peggy"
        team = "burritos"
    }
}
```

I can use the map in a `for_each` loop like so:

```terraform
resource "fake_resource" "teams" {
    for_each = local.map_of_objects
    name = each.key
    team = each.value["team"]
}
```

And now I'll have the following resources:

```hcl
fake.resource.teams["John"] = {
    name = "John"
    team = "tacos"
}

fake.resource.team["Peggy"] = {
    name = "Peggy"
    team = "burritos"
}
```

Which I can refer to by name instead of index.

The more concrete example in my `tfe` module is with the creation of teams and assigning users to teams.

```terraform
# Create workspaces
resource "tfe_workspace" "workspaces" {
  for_each          = { for workspace in local.org_data.workspaces : workspace["name"] => workspace }
  name              = each.key
  description       = each.value["description"]
  terraform_version = each.value["terraform_version"]
  organization      = local.organization_name
  tag_names         = each.value["tag_names"]
}

# Configure workspace access for teams
resource "tfe_team_access" "team_access" {
  count        = length(local.workspace_team_access)
  access       = local.workspace_team_access[count.index].access_level
  team_id      = tfe_team.teams[local.workspace_team_access[count.index].team_name].id
  workspace_id = tfe_workspace.workspaces[local.workspace_team_access[count.index].workspace_name].id
}
```

Referring to the correct `workspace_id` is done by looking it up by `workspace_name`. If I had used a `count` meta-argument to create the workspaces, I would have to scan through each instance of the workspaces, filtering on the one with the correct name. 

Would it work? Sure. Is it less efficient and kind of crappy? Yes.

In the case of the `tfe_team_access` resources, I am not planning to refer to them anywhere else in the module, so it's safe to use a `count` argument. The only other concern would be the addition of a new access permission that changes the order. Let's test that.

The current `local.workspace_team_access` value looks like this:

```hcl
[
  {
    "access_level" = "admin"
    "team_name" = "org_admins"
    "workspace_name" = "app1-aws-staging"
  },
  {
    "access_level" = "plan"
    "team_name" = "app1-developers"
    "workspace_name" = "app1-aws-staging"
  },
  {
    "access_level" = "read"
    "team_name" = "security"
    "workspace_name" = "app1-aws-staging"
  },
  {
    "access_level" = "admin"
    "team_name" = "org_admins"
    "workspace_name" = "app1-aws-dev"
  },
  {
    "access_level" = "plan"
    "team_name" = "app1-developers"
    "workspace_name" = "app1-aws-dev"
  },
  {
    "access_level" = "read"
    "team_name" = "security"
    "workspace_name" = "app1-aws-dev"
  },
  {
    "access_level" = "read"
    "team_name" = "security"
    "workspace_name" = "app1-aws-prod"
  },
]
```

Now I add the compliance team to the staging workspace:

```hcl
[
  {
    "access_level" = "admin"
    "team_name" = "org_admins"
    "workspace_name" = "app1-aws-staging"
  },
  {
    "access_level" = "plan"
    "team_name" = "app1-developers"
    "workspace_name" = "app1-aws-staging"
  },
  {
    "access_level" = "read"
    "team_name" = "compliance"
    "workspace_name" = "app1-aws-staging"
  },
  {
    "access_level" = "read"
    "team_name" = "security"
    "workspace_name" = "app1-aws-staging"
  },
  {
    "access_level" = "admin"
    "team_name" = "org_admins"
    "workspace_name" = "app1-aws-dev"
  },
  {
    "access_level" = "plan"
    "team_name" = "app1-developers"
    "workspace_name" = "app1-aws-dev"
  },
  {
    "access_level" = "read"
    "team_name" = "security"
    "workspace_name" = "app1-aws-dev"
  },
  {
    "access_level" = "admin"
    "team_name" = "org_admins"
    "workspace_name" = "app1-aws-prod"
  },
  {
    "access_level" = "plan"
    "team_name" = "app1-developers"
    "workspace_name" = "app1-aws-prod"
  },
  {
    "access_level" = "read"
    "team_name" = "security"
    "workspace_name" = "app1-aws-prod"
  },
]
```

That changes the data structure, but does it mess with the deployment? In theory a `terraform plan` should only show 1 change.

```bash
Plan: 8 to add, 0 to change, 7 to destroy.
```

Oof, that's no good. The team associated with each existing resource has all shifted by one:

```bash
  # tfe_team_access.team_access[8] must be replaced
-/+ resource "tfe_team_access" "team_access" {
      ~ access       = "read" -> "plan"
      ~ id           = "tws-sPW7WjGmUPPjTA5X" -> (known after apply)
      ~ team_id      = "team-UFaGWZg3kicnHBqY" -> "team-BME5V6L3KBbTS7DB" # forces replacement
```

Curse you `count`! Looks like I'm better off using a `for_each` loop instead.

```terraform
resource "tfe_team_access" "team_access" {
  for_each        = { for access in local.workspace_team_access : "${access.workspace_name}_${access.team_name}" => access }
  access       = each.value["access_level"]
  team_id      = tfe_team.teams[each.value["team_name"]].id
  workspace_id = tfe_workspace.workspaces[each.value["workspace_name"]].id
}
```

```bash
Plan: 1 to add, 0 to change, 0 to destroy.
```

Ah, much better.