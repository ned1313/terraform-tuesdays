# Terragrunt Revisited

Four years ago, almost to the date, I did a review of Terragrunt. You can watch that video here through the doobly-doo (thank you Technology Connections for infesting my brain with that bit of terminology).

But good news! I watched it so you don't have to. And I thought it might be time to reassess my initial impressions of Terragrunt. It's four year later. Terraform has gone from version 0.14 to 1.9. OpenTofu happened. I switched my desk around and got a better camera.

So like I said, a lot has changed. Has my opinion of Terragrunt? Mostly no. Video over, we did it!

## Too Long Didn't Watch

I'm kidding. You have eyes, you see the run time of this video. You know I've got more to say. I'll start with a quick summary, and then we'll dig into a more thorough example of using Terragrunt and I'll point out where I think it adds value and where it probably doesn't.

Just like in the original video, I want to start by saying that I think Terragrunt is a well written application that does what it says on the label. There are no false claims here. Gruntworks espouses a philosophy of DRY configurations and disaggregated configurations, and they deliver on it with Terragrunt.

Also just like in the original video, I feel like I'm addressing two different types of viewers, those who are already using Terragrunt in their org and those who are considering it. And once again, I'll say that if you're using Terragrunt today, there is no reason for you to stop. If it is meeting your needs and not getting in your way, the switching cost is going to be far too high.

If you're not using Terragrunt today, but you're trying to solve some specific problems, I still don't think Terragrunt is the ideal solution, but that determination requires nuance and hence we have the remainder of the video. So buckle up y'all we're gonna get nuance-y.

## Terragrunt Quick Overview

For the uninitiated, Terragrunt is a wrapper around Terraform or OpenTofu that orchestrates operations and generates code using HCL files. You can use Terragrunt to deploy multiple configurations from a single command. You can also construct a hierarchy with inheritance to automatically generate files and settings, and avoid repeating yourself in your configurations.

The core conceit of Terragrunt is that you want to use folder-based management for your Terraform configurations. If that doesn't sound appealing to you, then that would be the first red flag. What does a typical folder structure look like? Probably something like this.

We've got two top level folders here, one for environments and one for modules. Each environment is going to leverage the modules to build out a complete deployment. And each environment is going to be mostly the same as the others with some key differences, like subscriptions, VM sizes, and maybe storage classes.

To best illustrate how Terragrunt does its thing, why don't we start with this file structure, but assume we're managing it all with vanilla Terraform today.

### Current Configuration Overview

Okay, first let's look at the modules directory. I've got networking, frontend, backend, and db. Four different modules to deploy different components of the same configuration.

Now let's look at my development environment. 