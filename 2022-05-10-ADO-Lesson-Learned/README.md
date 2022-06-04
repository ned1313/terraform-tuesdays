# Lesson Learned about ADO

Since my original video and post about using Azure DevOps Pipelines to drive a Terraform workflow, I've had the chance to interact with the service a bit more extensively and I've learned a LOT about how to configure pipelines, set triggers, and even string things together. I thought it might be nice if I put that all together in a single video. So here we go!

## Azure DevOps Refresher

If you'd like to go back and watch the previous videos about ADO and Terraform, I invite you to do so. I think they were pretty good! But if you don't want to do that, I'll do my best to summarize here. 

Azure DevOps pipelines allows you to define a YAML-based pipeline that lives alongside the rest of your code. In my case, I wanted to use ADO pipelines to deploy and manage Terraform provisioned infrastructure. I also wanted to take advantage of some of the native pieces in Azure for Terraform, like Azure Storage for state data and Azure Key Vault for storing secrets.

I also wanted to include some error checking and compliance checking in my code leveraging Checkov and `terraform validate` to start.

The pipeline was built off different steps that would occur in a GitOps style workflow. The flow went something like this:

* Each infrastructure update starts as a feature branch from main
* Updates are checked into GitHub on the feature branch and automatically checked for formatting and valid code
* When code is ready, a PR is issued from the feature branch to the main branch, causing Checkov and `terraform plan` to run
* If the code tests clean, the PR is merged, and the target environment is updated using the code

That's the workflow in a nutshell. Seems pretty simple right? If it doesn't, go back and watch the videos, and then it will hopefully make sense.

## What I Learned

I had to delve pretty deeply into ADO for a series of liveProjects I was authoring for Manning publications. In the process, I learned a lot about how ADO pipelines handle triggers, when to use bash scripting, and what to do about Terraform state.

### ADO Pipeline Triggers

First of all, the word trigger is used in two different contexts, which makes things super confusing. You can speak generally about a pipeline trigger as anything that starts up the pipeline. But in the YAML syntax for pipelines, `trigger` is a keyword used to track commits made to a repository on one or more branches. 

When I am talking about *triggers* in the abstract, I'll try and use *italics* to make it clear. When I'm talking about the keyword `trigger`, I'll put it in monospace. 

There are many ways to *trigger* a pipeline, allow me to enumerate them!

1. Using `trigger` you can watch a repository for changes
1. Using `pr` you can watch a repository for pull requests
1. Using `schedules` you can fire on a regular schedule
1. Using one of several `resource` keywords, you can watch other resources for a change
  a. For instance, you can watch another pipeline with the `pipeline` resource keyword and *trigger* based on a successful or failed run

Here's a few important things to know about each trigger type:

* If you specify no `trigger` block in your pipeline, the pipeline will *trigger* on **every** push to the repository.
* If