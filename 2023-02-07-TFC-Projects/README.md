# Terraform Cloud Project

Guess what?! That thing I've been complaining about for the last 2 years is finally here! Terraform Cloud Projects! Before we get into exactly what they are, here's a little background for those who might not be familiar with my previous rants.

## Background

Terraform Cloud separates things into Organizations and Workspaces inside Organizations and that where the hierarchy ends. As someone who comes from a Microsoft background, I'm used to multiple hierarchical layers for administrator and security reasons. Active Directory OUs, Azure Management Groups, File Servers, etc.

Having a flexible hierarchy construct is useful for organizing things, but also useful for apply permissions that are inherited by the objects lower in the hierarchy. I can make you an administrator of an Azure subscription, and all the resources in that subscription will inherit that permission. That's super helpful!

I can also group all of my related resources inside the same subscription or resource group, making it easier for others to suss out which things are related. Also, when you're viewing things through a dashboard or UI, adding a layer of hierarchy makes it easier to find things.

Previous to the introduction of Project, all Workspaces in Terraform Cloud existed in a flat hierarchy. This meant that if you wanted to apply permissions to a group of Workspaces, you had to do it one by one. While it is possible to use Terraform to configure Terraform Cloud, that's not the best solution in my view. Tags for Workspaces were introduced in part to help with filtering and provide additional metadata about a given workspace, but they didn't do anything to alleviate the pain of managing permissions.

Now I think we're ready to talk about Projects.

## Introducing Terraform Cloud Projects

A Project in Terraform Cloud is a container for Workspaces. Every Workspace needs to be a member of a Project. Existing Workspaces have been automatically placed in the Default Project, which is in fact called "Default Project", space and all.

You can create new Project and move Workspaces between Projects as needed. When you create a new Workspace, you should specify the Project it should be a member of. If you don't specify a Project, it will be placed in the Default Project.

Speaking of the Default Project, you can rename that Project, but you cannot delete it. After all, Terraform Cloud needs to put all of your existing and new Workspaces somewhere, and if you don't specify a Project, it will go in the Default Project.

## Creating a Project

You can create a Project through the UI, API, or using Terraform. The `tfe` provider has been updated to include the `tfe_project` resource. You can find the documentation for that resource [here](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project).

## Using the CLI Workflow with Projects

If you are using the CLI workflow with Terraform Cloud, then you know that you have to use the `cloud` or `remote` block to use Terraform Cloud as a backend. As of right now, neither has any idea about Projects.

In fact, the Workspace config at the CLI level is completely unaware of the existence of Projects. It doesn't show up in the local state file, and there's no option to specify a Project in either block type.

It also doesn't matter if you move the Workspace to a different Project. You local CLI workflow will continue to function without issue. I think that's kind of weird, but also keeps the addition of Projects from breaking existing deployments.

> An interesting side effect is that each Workspace still needs to be uniquely names across the entire Organization, even if a new Workspace would be in a different Project.

If you create a new Workspace through the CLI workflow, it will be placed in the Default Project. You can then move the Workspace to a different Project through the UI or API.

If you're using the VCS workflow, then all of this is moot. You don't use the `cloud` or `remote` blocks with the VCS workflow. You would assign the correct Project when you create the Workspace for the VCS connected repo.

## Permissions

Now that we have Projects, there are a few things to consider when it comes to permissions. Who can create a Project? Who can move Workspaces between Projects? Who can delete a Project? Who can view a Project?

Let's walk each of these in turn.

### Organization Level Permissions

Project permissions are managed at the Organization level. There are two new permissions that govern Projects and Workspaces. The first is View all Projects and Workspaces. It pretty much does what it implies. The second is Manage all Projects and Workspaces. This permission allows you to create, edit, and delete Projects and Workspaces, as well as move Workspaces between Projects.

There are still Organization level permissions that just govern Workspaces. For instance, there's `View workspaces only`. Is that person able to see all Workspaces regardless of what Project they are in? Yes! Yes they can. I assume this is because HashiCorp didn't want to break anyone's existing permissions. But I don't love it. There's also a `Manage workspaces only` permission that allows you to create, edit, and delete Workspaces, but not Projects. Someone with that permission can edit and delete any Workspace, regardless of Project, but can only create a new Workspace in the Default Project.

Again, I don't love this. I'd rather the existing permissions be restricted to the Default Project, and then have new permissions for all other Projects and the Workspaces inside.

### Project Level Permissions

Each Project can have permissions associated to various teams. As usual the Owners team has full permissions. Beyond the owner association, there are two Access Levels: Read and Admin. Read can read the Project name and the Workspaces inside the Project. Admin can do just about everything, including the following:

* All read permissions
* Admin for all Workspaces inside the Project
* Move workspaces *(more on that in a moment)*
* Edit the project
* Manage team access to the project
* Delete the project
* Create workspace in the project

The `Move workspaces` permission is interesting. Where can they move a Workspace to? The answer is any other Workspace that they have Admin permission on. So if Bob has Admin permission on Project A and Project B, he can move a Workspace from Project A to Project B. Good job Bob!

### Workspace Permissions

You remember like 800 words ago when I said that I wanted to assign permissions based on hierarchy? Projects lets you do that, kind of. You cannot assign Workspace type permission at the Project level. For instance, if I wanted to give Bob `Plan` permissions on all the Workspaces in Project A, I can't do that at the Project level. I can grant Bob `Read` access or `Admin` access at the Project level, but not the other Workspace specific permissions. Do I love this? Again, no.

The Project level permissions also include Project level access, which I might not want to grant to Bob. Maybe I want to grant `Read` access to the Project and `Admin` access to the Workspaces inside. The `Admin` Project level permission would grant Bob too much access, and that's no bueno for to principle of least privilege.

## Improvement and Closing Thoughts

I'm very glad to see Projects rolled out to Terraform Cloud and I'm certain that it will evolve and improve over time. In fact, I'm in contact with the product team over at HashiCorp, so if you have any feedback, please let me know!

For my part, I'd like to see the following improvements:

* Add a `project` argument to the `cloud` block for the CLI workflow
* Allow Workspace type permissions to be assigned at the Project level
* Restrict older Organization level workspace permissions to the Default Project
* Duplicate Workspace names in separate Projects (this might seem strange, but I think it would be useful)
* Inherited permissions shown in the UI

What are your thoughts on Projects? Do you have any feedback for HashiCorp? Let me know in the comments!