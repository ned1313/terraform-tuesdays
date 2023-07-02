# Introducing the Terraform Import Block

Terraform 1.5 includes the new import block, and it's a game changer! This new feature makes importing existing infrastructure far easier than the older import command. Let's dig into how it works, why it's better, and what gaps still exist.

Welcome to Terraform Tuesday!

## Welcome

Hey everyone! I'm Ned Bellavance, ned in the cloud dot com, and welcome to another episode of Terraform Tuesday. Today we're going to be talking about the new import block in Terraform 1.5.

When you first start using Terraform, there's a non-zero chance you already have infrastructure deployed and you may want to bring that existing infrastructure under management with Terraform. While that was possible with the older import command, it was quite painful.

## Import Command Workflow

The older process for importing resources into Terraform management used the import command. The workflow was to first run the terraform import command with the desired address of the resource in your configuration and the unique identifier of the resource in the existing environment.

The import command would poll the existing resource and gather the attributes of that resource, and then it would create a state data entry for it using the desired address you specified. It would not create the resource configuration block in your Terraform code, that was up to you.

The next step was to create that resource block yourself and run a Terraform plan to see if any changes were required. If you did everything right, you would see no changes required and you could safely run a Terraform apply to bring that resource under management.

There were several shortcomings to using the import command.

### Import Command Problems

First of all, the import command directly edited the state data without generating an execution plan. You didn't have a chance to preview changes before they were made. That's not great.

Even worse, between the time you ran the import command and the time you added the resource block and applied it, your imported resource was in a precarious position. Why?

Think about what Terraform sees if someone ran a Terraform apply before you added the resource configuration block. Terraform would see a resource in the state data that was not in the configuration. It would assume that resource was deleted and would attempt to destroy the actual resource. That's um... That's bad.

It's unlikely that you would do this to yourself, but if you're in a collaborative environment with remote state, you better make sure everyone else knows you're importing a resource and to pause on any work till you're done.

The second problem is that the import command only allowed adding a single resource at a time. If you had a lot of resources to import, you had to run the import command over and over again. And every time Terraform would have to establish a connection to the existing resource to gather its attributes. Importing 100 resources could take an hour or more!

Plus, as we already discussed, each of those import commands would alter the state data. Hope you got all 100 commands right!

Lastly, the import workflow required you to generate the resource configuration blocks yourself. That's not a showstopper, but you'd think since Terraform can see all the attributes and it knows the structure of the resource, it could probably generate a basic resource block for you. But it didn't.

Guess what? The new import block solves all of these problems!

## Import Block Process

The new import block is essentially a replacement for the import command. It was introduced in Terraform 1.5, and the process is similar to any other Terraform workflow.

You first add the import blocks to your configuration. The syntax for the block is dead simple. It's the keyword import, followed by a to argument that specifies the desired address of the resource in your configuration, and then an id argument that specifies the existing resource's unique identifier. That's it!

Once you've added your import blocks to the configuration, you run a Terraform plan to see what changes will be made. If you're happy with the plan, you run a Terraform apply to bring the resources under management. Once you're done you can remove the import blocks from your configuration.

You can add as many import blocks to your config as you want, so you're not limited to one at a time.

And you'll see the proposed changes to state, as well as any changes to the imported resources based on what's in your configuration. Typically, you would want to see any changes to the imported resources, because you want to make sure that the configuration matches the actual resource.

Since it's a purely declarative process, if someone else is also working on the environment, you won't have a situation where changes have been made to the state data, but the configuration isn't ready yet.

## Generating Resource Blocks

What about the creation of the resource blocks? Well, there's now an experimental feature that will help you will generating the resource blocks. It's a new flag with the plan command called -generate-config-out and you set it equal to a file where you would like the resource blocks to be created.

Terraform will first create query the objects based on the import blocks, generate the configuration, and then run a standard plan to validate the generated blocks and detect any changes.

You can review the contents of the blocks, make alterations as necessary, and then run a plan without the -generate-config-out flag to see the results.

As we'll see in one of the examples, this is still an experimental feature, so it's likely to get some portion of the resource configuration wrong. But it does give you a good starting point to build out your configuration.

Let's dig into a couple examples.

## Basic Import Block Example

As always, the code for the examples in this video are available in the description below. In the first example, let's say we already have a virtual network in Azure that we are managing with Terraform. I have already run a Terraform apply to create it. The virtual network has two subnets in it.

Now, let's say that someone requests a new subnet. And your junior admin, let's call them Chris, Chris doesn't know about Terraform, but they're trying to be helpful. So they pull up the terminal and add a third subnet using the Azure CLI.

Crap Chris, that's not how we do things! Now we have a subnet that's not under Terraform management. We need to bring it under management, and we can do that with the import block.

## Generate Config Out Example

For the next example, in this case we have a deployment in Azure that was created with an ARM template, and now we want to bring those resources under Terraform management. We'll use the -generate-config-out flag to help us create the resource blocks instead of doing it manually.

I've already used the Azure CLI to create a resource group and deploy the ARM template. The nice thing is that the results of an ARM template deployment include all the resource IDs of the resources created. We can grab those IDs and add them into our import blocks. One weird one is the NIC to NSG attachment, which is a resource that doesn't really exist in Azure, but Terraform needs it. So that import ID will be a little unique.

## Import Block and Process Thoughts

The import block is a great addition to Terraform, because it makes the process of importing existing resources declarative and predictable. It's a definite improvement over the old import command. But that doesn't mean it's perfect.

The -generate-config-out flag is still experimental, and it's not going to get everything right. And it doesn't understand resource dependencies, resource references, or anything else that's not a direct attribute of the resource. So you'll still have to do some manual work to get the resource blocks right.

The import process also doesn't discover your existing resources for you or extract the unique identifiers. You still have to do that yourself. That's not a big deal if you are just importing a few resources, like in our subnet example. But if you need to import everything in an Azure subscription or an AWS account, that could be a huge pain.

There are some excellent third-party tools that can help you with that. For Azure specific resources, there's the Azure Terraform Export Tool, formerly called Azure Terrafy. I did a whole video on that a while back. The team maintaining the tool is looking into how they can incorporate the import block into their existing workflow.

For AWS or GCP, there's the Terraformer tool, which I had some trouble with a few years back, but I hear it's gotten a lot better. There's also vendors who offer commercial tools to help with this process. One such tool I'm pretty intrigued by is Firefly. They seem to do a lot more than just import resources, stay tuned for a possible future video on that.

## Final Thoughts

HashiCorp has been slowly moving all Terraform operations to a declarative approach, and the import block is a great example of that. It's been a big ask from folks for a long time and I'm pumped to see it get the first party support it deserves.
