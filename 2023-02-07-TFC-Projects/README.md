# Terraform Cloud Projects

Guess what?! That thing I've been complaining about for the last 2 years is finally here! [Terraform Cloud Projects](https://www.hashicorp.com/blog/terraform-cloud-adds-projects-to-organize-workspaces-at-scale! Before we get into exactly what they are, here's a little background for those who might not be familiar with my previous rants.

<iframe width="560" height="315" src="https://www.youtube.com/embed/tDexI54Cjs8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## Background

Terraform Cloud separates things into *Organizations* and *Workspaces* inside organizations, and that is where the hierarchy ends. As someone who comes from a Microsoft background, I'm used to multiple hierarchical layers for administrative and security reasons. Active Directory OUs, Azure Management Groups, File Servers with NTFS permissions, etc.

Having a flexible hierarchy construct is useful for organizing things, but also useful for applying permissions that are inherited by the objects lower in the hierarchy. I can make you an administrator of an Azure subscription, and all the resources in that subscription will inherit that permission. That's super helpful!

I can also group all of my related resources inside the same subscription or resource group, making it easier for others to suss out which things are related. Bonus, when you're viewing things through a dashboard or UI, adding a layer of hierarchy makes it easier to find things.

Previous to the introduction of projects, all workspaces in Terraform Cloud existed in a flat hierarchy. This meant that if you wanted to apply permissions to a group of workspaces, you had to do it one by one. While it is possible to [use Terraform to configure Terraform Cloud](https://nedinthecloud.com/2022/02/03/managing-terraform-cloud-with-the-tfe-provider/), that's not the best solution in my view. Tags for workspaces were introduced to help with filtering and provide additional metadata about a given workspace, but they didn't do anything to alleviate the pain of managing permissions.

With all that in mind, I think we're ready to talk about projects.

## Introducing Terraform Cloud Projects

A *project* in Terraform Cloud is a container for *workspaces*. Every workspace needs to be a member of a project. Existing workspaces have been automatically placed in the Default Project, which is in fact called "Default Project", space and all.

You can create new projects and move workspaces between projects as needed. When you create a new workspace, you will be prompted to select the project it should be a member of. If you don't specify a project, it will be placed in the Default Project.

Speaking of the Default Project, you can rename that project, but you cannot delete it. After all, Terraform Cloud needs to put all of your existing and new workspaces somewhere, and if you don't specify a project when you create a new workspace (perhaps with the CLI) the Default Project is where it lands.

## Creating a Project

You can create a project through the UI, API, or using Terraform. The `tfe` provider has been updated to include the `tfe_project` resource. You can find the documentation for that resource [here](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project).

## Using the CLI Workflow with Projects

If you are using the CLI workflow with Terraform Cloud, then you know that you have to use the `cloud` or `remote` block to use Terraform Cloud as a backend. As of right now, neither block has any idea about projects.

In fact, the workspace configuration at the CLI level is completely unaware of the existence of projects. It doesn't show up in the local `terraform.tfstate` file, and there's no option to specify a project in either block type.

Fortunately, it doesn't matter if you move the workspace to a different project after it's created. You local CLI workflow will continue to function without issue, assuming your account still has access to the workspace in the destination project. It bothers me that the `cloud` and `remote` block don't have a project argument, but this approach also kept the addition of projects from breaking existing deployments.

> An interesting side effect is that each workspace still needs to be uniquely named across the entire organization, even if two workspaces with the same name are in a different projects.

If you create a new workspace through the CLI workflow, it will be placed in the Default Project. You can then move the workspace to a different project through the UI or API. Alternatively, you can pre-create the workspace in the correct project, and then use the CLI workflow for deployments.

If you're using the VCS workflow, then all of this is moot. You don't use the `cloud` or `remote` blocks with the VCS workflow. You would assign the correct project when you create the workspace for the VCS connected repo.

## Permissions

Now that we have projects, there are a few things to consider when it comes to permissions. Who can create a project? Who can move workspaces between projects? Who can delete a project? Who can view a project?

Essentially, there are three levels of permissions: *Organization*, *Project*, and *Workspace*.

Let's walk each of these in turn.

### Organization Level Permissions

Project permissions are managed at the organization level. There are two new permission sets that govern projects and workspaces. The first is *View all Projects and Workspaces*. It pretty much does what it implies. The second is *Manage all Projects and Workspaces*. This permission allows you to create, edit, and delete projects and workspaces, as well as move workspaces between projects.

There remains two vestigial permission set at the Organization level that only govern workspaces. These are the permission sets that existed before the introduction of projects, and HashiCorp chose to introduce new permission sets rather than expand the existing one.

There first is *View workspaces only*. Can a person with that permission set see all workspaces regardless of what project they are in? Yes! Yes they can. I assume this is because HashiCorp didn't want to break anyone's existing permissions. But I don't love it. You might move a workspace into a the `Super Secret Project` thinking you've hidden it from view only to discover that's not the case.

There's also the `Manage workspaces only` permission set that allows you to create, edit, and delete workspaces, but not projects. Someone with that permission set can edit and delete any workspace, regardless of project, but can only create new workspaces in the Default Project. Again, the approach here seems to be to not break existing permissions.

Again, I don't love this. I'd rather the existing permissions be restricted to the Default Project, and then have new permissions for all other projects and the workspaces inside. Regardless, when you view a workspace you don't see the permissions it inherits from the organization or project level. When it comes to security, that type of visibility is important.

### Project Level Permissions

Each project can have permissions associated to various teams. As usual the *owners* team has full permissions. Beyond the owner association, there are two access levels: *Read* and *Admin*. Read can read the project name and the workspaces inside the project. Admin can do just about everything, including the following:

* All read permissions
* Admin for all Workspaces inside the project
* Move workspaces *(more on that in a moment)*
* Edit the project
* Manage team access to the project
* Delete the project
* Create workspaces in the project

The `Move workspaces` permission is interesting. Where can they move a workspace to? The answer is any other workspace that they have Admin permission on. So if Bob has Admin permission on Project A and Project B, he can move a workspace from Project A to Project B. Good job Bob!

I should note that you cannot delete a project that has workspaces in it. You must first delete or move all the workspaces out of the project before you can delete it.

### Workspace Permissions

You remember like 800 words ago when I said that I wanted to assign permissions based on hierarchy? Projects lets you do that, kind of. You cannot assign the workspace level permissions at the project level. For instance, if I wanted to give Bob *Plan* permissions on all the workspaces in Project A, I can't do that at the project level. I can grant Bob *Read* access or *Admin* access at the project level, but not the workspace level specific permissions. Do I love this? Again, no.

The project level permissions also do not allow you to set granular permissions for the project or the workspaces inside. This is unlike workspace permissions, that allow you to select pre-canned access levels (like *Plan*) or create your own custom permissions set. Maybe I want to grant Alice *Read* access to the project and *Admin* access to the workspaces inside. The Admin project level permission set would grant Alice too much access, and that's no bueno for to principle of least privilege.

## Improvement and Closing Thoughts

I'm very glad to see projects rolled out to Terraform Cloud and I'm certain that it will evolve and improve over time. In fact, I'm in contact with the product team over at HashiCorp, so if you have any feedback, please let me know!

For my part, I'd like to see the following improvements:

* Allow workspace level permissions to be assigned at the project level
* Enable custom permissions sets at the project level
* Add a `project` argument to the `cloud` block for the CLI workflow
* Restrict older organization level workspace permissions to the Default Project
* Duplicate workspace names in separate projects (this might seem strange, but I think it would be useful)
* Inherited permissions shown in the UI for projects and workspaces

What are your thoughts on projects? Do you have any feedback for HashiCorp? Let me know via Twitter or LinkedIn!
