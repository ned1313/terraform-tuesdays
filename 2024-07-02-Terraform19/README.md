# Input Variable Validation Improvement

What's this? A new version of Terraform. And it does variable validation using multiple variables? Let's try it out.

## Introduction

This is meant to be a quick one. I know I say that all the time and then the video ends up being 30 minutes of something, but THIS TIME I MEAN IT. Terraform 1.9 dropped on June 26th and it has an improvement I'm pumped about.

## Variable Validation

The `variable` block type includes the option to specify one or more `validation` blocks inside it. Those validation blocks include two arguments:

* `condition` - with a value that is true or false
* `message` - the message to print if validation fails

Validation blocks are pretty cool and I recommend using them.

### Limitations

The problem with variable validation blocks is that they can only reference the variable value being tested. I can't reference other variables, local values, data sources, resources, nothing. This made validation somewhat less dynamic than you might want. Consider the following:

Here's an input variable that checks if a vm_size is in an allowed list. The list is stored with the variable block. So if I want to change that list, that's a code change to the config. Wouldn't it be nice if I could pull that list from somewhere?

Here's an input variable that uses a subnet, wouldn't it be nice to check and see if that subnet actually exists?

Or what about this configuration, where I want to use two different regions and make sure they aren't the same?

The good news is that with the release of Terraform 1.9, the validation block can refer to any other object in the same module. The only restriction is that Terraform needs to know the value during the plan, so you can't refer to a resource attribute that is only known after an apply.

Data sources are loaded during plan, so that should be safe.

Let's give it a try!

## Location Example

So here's a configuration that has two input variables. The first is `location` and this would be my first or primary location for a deployment. The second is called `partner_location` and I probably don't want it to be the same as my primary location. That would be silly!

To check that, I simply added a validation block with the condition that the partner location is not equal to the primary location. If it is, I'll get back an error message.

To test it, I have a `terraform.tfvars` file that has eastus for the location and westus for the partner location. I'll run terraform plan, and once it finishes its process, everything comes back green.

Now I'll change the partner location to be eastus and run terraform plan a second time. This time the validation fails and I get a helpful error back. Neat!

What about using a data source?

## Network Example

I've deploy a virtual network with three subnets in it: web, app, and db. In this deployment I want to use one of the subnets, but I want to make sure that subnet actually exists.

I've added a virtual network data source, and input variables for the virtual network name and resource group. The virtual network data source has a subnets attribute that is a list of subnet.

For the `subnet_name` input variable, I've added a validation block that uses the contains function to check and see if the subnet name value is in the list of subnets from the data source.

Once again, I have a terraform.tfvars file with the correct virtual network and resource group in it.

At the command line, I'll run terraform plan -var subnet_name="web" and after a few moments the plan comes back successful.

Now let's try a subnet name that's not in the virtual network, like tacos for instance. This time it comes back with a failure and the error message.

Pretty useful stuff!

## Final Thoughts

While it was possible to do this type of checking using pre or post condition blocks for resources and data source, I think this catches things earlier on in the evaluation cycle. Overall this is an excellent addition to the existing variable validation block and I'm excited to see it!

And that's all! See, I told you this would be short. I am trying to leave for vacation after all.

Thanks for watching. Like, subscribe, and go touch some grass or sand. You've earned it! Until next time, keep calm and Terraform on.
