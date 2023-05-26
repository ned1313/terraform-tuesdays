# Terraform Workspaces are Bad Actually, and Here's Why

In a previous post, I highlighted the new `-or-create` flag in the `terraform workspace select` command. As part of that post, I made an off-hand comment about how HashiCorp no longer recommends using OSS workspaces for production environments and how I had some *opinions* about that. I got a lot of feedback on that comment, so I thought I'd dig into it a bit more.

This is going to be more of a long-form discussion than a typical how-to video, so if you're just interested in how to use Terraform workspaces, you might want to check out a previous video on the topic. But if you're interested in the why behind the what, then read on.

## Introduction

I first discovered terraform workspaces back when they were still called environments and I thought they were the bees knees. But as I've used Terraform more and more I've come to realize that there are some serious potential problems with the open source version of Terraform workspaces, and I'm not the only one.

HashiCorp has updated their guidance on the use of Terraform workspaces, essentially saying that they're good for development and temporary environments, but not for production usage. Why not? And what should you do instead? That's what we're going to dig into today.

## The Problem

I think we have to start with first principles. What is problem is Terraform workspaces trying to solve? The main challenge is supporting multiple environments with the same basic body of code. So, for example, I might have a development, staging, and production environment, and I want to use the same Terraform configuration for all three. Each environment is going to have some elements of commonality and some differences. For example, the production environment is probably going to be the most robust, with more and bigger servers, enhanced security, locked-down permissions, a full-scale firewall or WAF, more performant storage, and production grade databases. That would be overkill for a development environment, where things are going to be scaled down to a more reasonable level, since the goal is usually to test functionality, not performance. Staging might be a mix of the two, with some production-level elements and some development-level elements.

I need to manage and maintain all of these environments that are similar in nature, but not exact copies. Layer on top of that, I probably want to reuse as much code as possible and minimize the administrative overhead of managing these environments. I also have to maintain a separation of concerns and access between the various environments. My developers probably shouldn't have access to production information and shouldn't be able to deploy updates without going through a change process. Whether it's an actual code promotion process or just a manual copy of code from one environment to another, I need to be able to control permissions and access to the various environments.

## Possible Solutions

Terraform workspaces are one way to deal with this problem. However, we are going to run into issues quickly. Other possible solutions include:

* Using environments in GitHub Actions or a similar feature in other tools
* Maintaining each environment in a separate directory of the same repository
* Using separate branches for each environment with promotion rules and permissions
* Using a separate repository for each environment and copying changes between them

I'm not going to go through each of these solutions in detail because the focus here is on Terraform workspaces. If you'd like to hear more about each of these approaches, let me know! I can certainly do a follow-up video on each of them.

## The Problem with Terraform Workspaces

To best understand the problem with Terraform workspaces, it's important to first understand how they work under the covers. When you create a Terraform workspace, you are essentially creating a new instance of state data. Each workspace is going to be using the same configuration files, the same providers and modules (including versions), and the same state backend. The differentiation between environments is going to be from the values used for input variables and how they are interpreted by the configuration. You also have access to the workspace name from within the configuration using the `terraform.workspace` value. You can use that to conditionally create resources, control naming, select sizing, and other parameters based on the environment. In fact, you could have all your values for each environment stored in a data source, and access the data source with the workspace name as an argument to get the appropriate values for the environment.

Whether you choose to use variables value files (`.tfvars`) per workspace, source your values from a data source, or inject them at run time from a CI/CD pipeline, the end result is the same and doesn't really matter. The issue with Terraform workspaces comes from the shared code base, shared state, and shared providers and modules.

### Shared Code Base

Having a shared code base across your environments is a good thing. It reduces the amount of code you have to maintain, but problems arise when you want to make a change to the code base and test it before rolling it out in production. How would you make such a change? Well, if you're not using source control, 1) that's weird, you should probably change that and 2) any changes you make to your code with be equally applied to all workspaces. Let's walk through an example.

Let's say I've got three environments (dev, staging, and prod) each using a Terraform workspace and leveraging the same code. When I want to make a change, I update the code, switch to the dev workspace, and run a Terraform plan. Things look good and I apply the change to the dev workspace. Then I switch to the staging workspace, run a plan and apply, and then finally do the same for prod. That works great if it's just me. But if I'm trying to work in a team, changes that were made and being tested in dev may accidentally be applied to the staging or prod environments if I'm not careful. The typical way around this is to either duplicate the code base for each environment in its own directory, or create a separate branch for each environment. If you've created a directory for each environment, then you don't need workspaces because you're no longer sharing code. Likewise, if you have a separate branch for each environment, then you're also no longer using the same exact directory for each environment, you're using the code in that branch and commit. In either case, you no longer need to use Terraform workspaces. For the directory situation, I can tell which environment I'm managing from the `path.cwd` value and for the branch situation, I can inject the branch name as part of the Terraform run.

Either of those solutions doesn't require the use of Terraform workspaces. And it also frees you up to store your state data in a separate location for each environment, which might be a good thing.

### Shared State

All the workspaces associated with a Terraform configuration will share the same state backend. That's not necessarily a problem, but it does mean that each environment will must have access read/write access to its state data, and it probably will get access to all the others unless you do some seriously granular permissions, and you backend of choice supports it. Let's take a look at how the state data is stored on an Azure Storage Account.

Each workspace uses the same storage account and blob container, which you can think of as a directory, but it's really a prefix path. When you initialize Terraform, you will pass it the storage account information, including the container name and key to use for blobs. The default workspace will use the key value alone, so if my key value is `AppA.tfstate` the blob will be named `AppA.tfstate`. Each additional workspace will get the same blob name with `env:` and the workspace name appended. So if I have a workspace named `dev`, the blob name will be `AppA.tfstateenv:dev`.

Each workspace has its own state blob, but they will all be using the same Azure storage account and blob container. With the exception of Shared Access Signature tokens, the lowest level you can set permissions on Azure Storage is at the container level. Meaning that any client who has access to update one workspace, will also have access to view and modify the other environments including production. Since there tends to be sensitive information in the state data, this is a problem. Could you use SAS tokens? Sure. However, provisioning SAS tokens is a pain, outside of automation scenarios. You know what's way easier? Using a separate storage account or container for each environment. Maybe you have a storage account that is dedicated to holding state data for production workloads and you have it locked down three ways from Sunday. If that's the case, you can't use Terraform workspaces.

And that's just if you happen to be using the Azure Storage backend. I'm sure the other backend options are fraught with similar issues. The shared state backend of workspaces is a big security risk and Terraform OSS doesn't have the permissions model to handle it.

### Shared Providers and Modules

There's nothing inherently wrong with shared providers and modules. In fact, you should be using the same providers and modules across your environments. But you might not want to use the same versions of each module and provider right away. And that's not a choice you can make with workspaces. They have a common `.terraform.lock.hcl` file and the version constraints are part of the configuration itself. So we're back to the same issue as the shared code base. If a new version of the AWS provider is released and I want to test it out in dev before promoting it to staging and prod, I would have to be very careful with my workspaces.

To upgrade in the first place, I would need to change my version constraints and then run `terraform init -upgrade` to update the lock file. That change will impact all workspaces, and it might not be nearly as obvious as other code changes. If someone else on my team is rolling out a change and they don't realize that I updated the version constraints, they could end up using that module or provider in production and cause issues or even downtime.

The solution, as before, is to instead split the environments into separate directories or branches. And again, in either case, you're not using Terraform workspaces anymore.

## Are Workspaces Bad Though?

I know I started this whole post with the catchy title of workspaces are bad actually. And for long lived environments where you plan to promote code changes and need strict separation of concerns, Terraform OSS workspaces are a bad solution. They just don't fit the requirements.

When would you use workspaces? Well, they are great for temporary environments where you want to do some quick testing with your code without impacting the long-lived environment. Maybe I'm trying something new with the code locally, and I don't want to blow up the shared dev environment. I can create a `temp` workspace and execute my changes there. If things look good, I can destroy the workspace and push the change to source control and let my usual CI/CD process take over. Or maybe I'm trying to test out a new module or provider version and I don't want to impact the other environments. I can create a workspace and test it out there. When I'm done, I can destroy the workspace and promote the change to the other environments. That could be especially useful where you're leveraging something like terratest. You can create a workspace, spin up a temporary environment, run your tests, and then destroy the environment when you're done.

I should also say that this is specific to Terraform OSS environments and not Terraform Cloud Workspaces. TFC workspaces deal with many of these issues by rolling out workspace level permissions, variable values, and tracking separate branches of a VCS repo. While the two types of workspaces seem similar, they are in fact quite different in practice.

## Conclusion

To sum it all up, Terraform OSS workspaces are good for temporary environments, but they fall short in many ways when it comes to managing long-lived environments. That's especially true if you're collaborating on a team or need separation of permissions for each environment and a well-defined code promotion process.

There are lots of other solutions out there to help you deal with separate long-lived environments. Terraform OSS workspaces just aren't it.

I'd love to hear your thoughts on this. Do you use Terraform workspaces? Do you have any other solutions you use to manage long-lived environments? Let me know in the comments below.