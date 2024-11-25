# Terragrunt Revisited

Four years ago, almost to the date, I did a review of Terragrunt. You can watch that video here through the doobly-doo (thank you Technology Connections for infesting my brain with that bit of terminology).

But good news! I watched it so you don't have to. And I thought it might be time to reassess my initial impressions of Terragrunt. It's four years later. Terraform has gone from version 0.14 to 1.9. OpenTofu happened. I switched my desk around and got a better camera.

So like I said, a lot has changed. Has my opinion of Terragrunt? Mostly no. Video over, we did it!

## Too Long Didn't Watch

I'm kidding. You have eyes, you see the run time of this video. You know I've got more to say. And I want to start with what I think my previous video got wrong or at least approaches incorrectly.

Throughout the older video, I kept saying how Terragrunt was meant to solve issues that existed with Terraform before recent developments. But I don't feel that I was ever really clear on what the exact shortcomings were and how updates to Terraform solved it.

That video was also shot long before I started writing scripts for the videos as well, so I pretty much just had an outline and riffed on that. I ended up repeating myself a lot without adding clarity. So in this video I plan to do a much better job.

We are going to start with the problems Terragrunt is trying to solve.

Then we will walk through an example, modifying an existing configuration to use Terragrunt, so you can see how it solves real problems.

After that, we'll talk about alternative solutions that exist both in Terraform natively and on various automation plaforms.

And finally, we'll get into some of the issues that Terragrunt introduces. But before that, one thing I'd like to say is that I think Terragrunt is a well written application that does what it says on the label. Gruntworks espouses a philosophy of DRY code and disaggregated configurations, and they deliver on it with Terragrunt.

I feel like I'm addressing two different types of viewers, those who are already using Terragrunt in their org and those who are considering it. If you're using Terragrunt today, there is no reason for you to stop. Assuming it meets your needs and isn't getting in your way, the switching cost is going to be far too high.

If you're not using Terragrunt today, but you're trying to solve some specific problems, I still don't think Terragrunt is the ideal solution, but that determination requires nuance and hence we have the remainder of the video. So buckle up y'all we're gonna get nuance-y.

## Terraform Problems

In my eyes, there are three problems Terragrunt is trying to address:

1. Managing large configurations with thousands of objects
1. Managing multiple environments that have the same basic config
1. Reducing code repetition by embracing DRY principles

Allow me to expand on each of these a little.

### Massive Configurations

If you've watched my Terraform Stacks video, you know that having a massive root module has become something of an anti-pattern. In some cases, the components in the same root module can't even deploy because of planning dependencies. You have to target specific resources to deploy first before you can deploy the rest of the configuration. In other cases, you start encountering excessive planning times when Terraform attempts to refresh state for the thousand plus resources in your root module. That massively slows down development and locks state for an excessive amount of time. If you're dealing with that kind of scope and sprawl, Terragrunt can help you break your root modules into smaller deployments, each with their own instance of state.

### Multiple Environments

There are roughly three common approaches to dealing with multiple environments: folder-based, branch-based, and logic based. If you've gone down the folder based approach, then you know it can be difficult to keep all your environments in sync. Wouldn't it be nice to define settings in a hierarchy and let each environment inherit those settings? Terragrunt sure seems to think so. If you're using branch or logic based, Terragrunt doesn't really have much for you.

### DRYing Out Your Code

The last big goal is to reduce the repetition in your code by allowing you to define settings in a hierarchy and declaratively generate files for your root module. Breaking up your massive configuration is less painful if you don't have to maintain a bunch of new backend and provider files for each new root module. And maintaining ten or twenty environments with this kind of inheritance reduces the need to update a bunch of terraform.tfvars files or something similar.

All of this might seem a little esoteric, so let's apply it to an actual example.

### Original Configuration

Over in VS Code I have an example configuration that we're going to transform with Terragrunt.

If you're looking for the files, you can always find them on my Terraform Tuesdays repo, the link is down below.

This application has three environments, dev, qa, and prod. Let's take a look at dev.

* Review the development environment
* Point out the backend settings in the block and backend.hcl file
* Review the modules supporting the environment
* Review the qa and prod setting
* Point out all the code duplication with the backend file, terraform.tfvars, terraform.tf, and providers.tf
* How do I easily update all this stuff? I'd sure like to define things a little different

### Explain the terragrunt HCL file

### Updating the Code

* Start by adding a terragrunt.hcl file to the dev enivronment
* Move the inputs to the terragrunt.hcl file

## Philosophy Time

Listen, you got this far in the video. I'm gonna drop some opinions. Some thoughts on IaC and automation. Feel free to disagree in the comments.

Terraform has to make design choices. What's in scope and what's out. Many of the things that Terragrunt is trying to address are things that Terraform has decided are out of scope. Things like configuring the backend dynamically, stitching together disparate configurations, deployment to multiple environments.

Terraform has some features that could help, there's the remote state data source to pull info from one config to another. You've got the Terraform Community Edition workspaces to help with multiple environments. And if you're willing to jump over to OpenTofu land, you can define the backend with variables now.

But basically, HashiCorp looked at those features, along with managing remote state, having a hierarchy variable values, and fully automating deployments and said, "That belongs in something else."

The direct result is that we have a plethora of Terrraform Automation platforms and solutions out there to fill in the gaps. Terragrunt is one of those solutions. HCP Terraform is another. Want to deal with multiple environment declaratively, have value inheritance, and not have to worry about the state backend, Terraform Stack will do that. And so will env0 and Spacelift and Atmos.

Terragrunt is fairly opinionated on how you should be managing your components and environments, namely with a complex folder structure. That's not necessarily bad, but it does lock you into their way of doing things and extracting yourself could be pretty difficult. I've talked to more that one person who doesn't really want to use Terragrunt anymore, but they also don't want to spend months refactoring everything and doing extensive state surgery. And make no mistake, splitting what would be a root module into 4 or more separate modules with their own state data does introduce its own set of problems.

For any reasonably sized configuration, you don't have split the root module up. And Terraform works better when you don't Remember the weird mock data thing we had to do? You don't have to do that when everything is part of the same root module. Eventually, it might make sense to break up the configuration, but I think the reasons to do that have more to do with blast radius, access permissions, and change rate.

With the introduction of moved, import, and removed blocks, actually moving stuff from one configuration to another (if necessary) is far less painful than it was in the past. Keeping things together makes it a lot easier to reference attributes of one resource in another.

When it comes to dealing with multiple environment, my mindset has been changing. I used to like branch-based management, but lately I think trunk based development with logic bundled into your root module is probably the way to go. You can add environment by adding tfvars file and having your automation take care of the rest. I plan to do a video demonstrating what that looks like, so keep an eye out.


