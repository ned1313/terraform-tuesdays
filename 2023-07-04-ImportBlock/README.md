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

Lastly, the import workflow required you to generate the resource configuration blocks yourself. That's not a showstopper, but you'd think since Terraform can see all the attributes and it knows the structure of the resource, it could probably generate a basic resource block for you. But it didn't.

Guess what? The new import block solves all of these problems!

## Import Block Process

## Import Block Syntax

## Import Block Example

## Final Thoughts