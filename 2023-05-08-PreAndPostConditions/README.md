# Using Pre and Post Conditions in Terraform

## Introduction

When it comes to developing good code, you need to sanitize your input, check your assumptions and make guarantees that can be relied on by the next link in the chain. This is true for all code, including Terraform. With this video, I thought I would explore how the use of pre and post conditions can make your Terraform code more reliable and easier to maintain.

## Validation

The name of the game when it comes to verifying assertions and making guarantees is validation. It all starts with the humble input variable, where you can use both the `type` and `validation` arguments to ensure that the input is of the correct type and value. I actually covered the validation argument in a previous video, so I won't into it now. Link is in the description and in the whosawasit thinger that appears above my noggin.

The upside is that you can catch validation issues early on, way before Terraform even has to load state data or draw its resource graph. When you're trying to iterate quickly, this is a huge benefit.

The downside of the validation block is that it is limited to only the variable value itself and anything you hardcode into the `condition` argument. You can check to see if a VM size is in a list of values, but that list needs to be hardcoded into the config. You can make sure a CIDR address is valid, but you can't grab a list of CIDR ranges from a data source to make sure it isn't being used.

The reason is because of when Terraform does the variable validation process in its workflow. The validation happens before the resource graph is drawn or the data sources are refreshed, so you can't reference anything in state or data sources within the validation block.

The answer to this is to use pre and post conditions in your resources and data sources.

## Pre and Post Conditions

Pre and post conditions were introduced in Terraform 1.2. They are a new argument that can go in the `lifecycle` meta-argument block, and they can be used with resources, data sources, and outputs. You can specify the `precondition` or `postcondition` block multiple times for an object.

```terraform
lifecycle {
    precondition {
        condition = true
        error_message = "This is an error message."
    }

    postcondition {
        condition = true
        error_message = "This is an error message."
    }
}
```

Just like the `validation` block for input variables, the pre and post condition blocks take a `condition` argument that resolves to `true` or `false` and an error message to display if the condition is not met. When Terraform encounters an error, it will stop processing. The point at which it stops processing depends on whether its a pre or post condition.

Let's look at preconditions first.

### Pre-conditions

Pre-conditions run before the object its associated with is evaluated. You can use a pre-condition on a resource, data source or output. Since the pre-condition is running before the object is evaluated that means two important things:

* You can't reference the object itself or its attributes in the pre-condition
* Terraform will fail on a pre-condition before it fails on an invalid object argument or value

The first point means you can't use the `self` expression to refer to attributes of the object you're running the pre-condition check on. The second point means that if you have an invalid value for an object argument, but the pre-condition fails, Terraform will only error on the pre-condition. It won't tell you about the invalid value until you fix the pre-condition. That's not necessarily a bad thing, but it's something to be aware of.

Pre-conditions can be thought of as assumptions that you're making about the state of the world before the object is evaluated. If the assumption is wrong, then the object can't be evaluated correctly. They also fail faster than the object instantiation itself - since it doesn't need to talk to the provider API and wait for a failure. That can be a good thing if you're trying to speed up your development process. I know that I waste a lot of time waiting for resource creation to fail because of bad input values. It'd be nice to know that the input values are bad before I even try to create the resource.

Terraform will do its best to run pre-conditions during the execution plan generation, but if you're referring to attributes of other objects in the pre-condition that are not know until the apply phase, then the pre-condition will be run during the apply phase. For instance, if you're referring to the value of a public IP address in the pre-condition for an Azure VM, that value isn't know until the public IP address resource is actually created, which happens during the apply phase.

Why don't we dig into some pre-condition examples, and then we'll cover post-conditions.

#### Pre-Condtion Examples

I'll start with an example where you can use a pre-condition block to make sure the resource group you were given as input is in the correct region.

```terraform
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "main" {
    name = "taconet"
    location = var.region
    resource_group_name = data.azurerm_resource_group.main.name
    address_space = ["10.0.0.0/16"]

    lifecycle {
        precondition {
            condition = var.region == data.azurerm_resource_group.main.location
            error_message = "The resource group ${var.resource_group_name} is not in the region ${var.region}"
        }
    }
}
```

In this case, we want to make sure that the region being used for the virtual network is the same as the region of the pre-existing resource group. This is useful when you're writing a module for someone else to use and you want to provide them the flexibility to use their own resource group, but you also want to make sure they're not going to shoot themselves in the foot by using a resource group in the wrong region.

If I run a `terraform plan` with a resource group in the wrong region, I get the following error:

```bash
│ Error: Resource precondition failed
│
│   on main.tf line 28, in resource "azurerm_virtual_network" "main":
│   28:       condition     = var.region == data.azurerm_resource_group.main.location
│     ├────────────────
│     │ data.azurerm_resource_group.main.location is "westus"
│     │ var.region is "eastus"
│
│ The resource group sopes-west is not in the region eastus
```

The pre-condition failed, as we would expect. And it failed during the plan phase, because our condition didn't include any attributes that are `(known after apply)`. That means our checks earlier in the process, and generally earlier is better.

Since the pre-condition can reference a data source, that means we have access to the `http` data source, which can be used to send a request to a URL. You might use that to check and make sure a service is ready before trying to provision a resource that depends on that service.

Another possibility is accessing stored configuration information in something like AWS SSM or Azure App Config. For instance, let's say I have the allowed CIDR ranges stored in Azure App Config under the key `cidr_lists` and I have labels for each region. I can use the `azurerm_app_configuration` data source to get the value of that key and then use the `contains` function to make sure the CIDR range I was given as input is in the list of allowed ranges.

```terraform
data "azurerm_app_configuration_key" "cidr_list" {
  configuration_store_id = var.app_config_store_id
  key = "cidr_lists"
  label = var.region
}

resource "azurerm_virtual_network" "main" {
  name                = "taconet"
  location            = var.region
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = [var.vnet_address_space]

  lifecycle {
    precondition {
      condition     = var.region == data.azurerm_resource_group.main.location
      error_message = "The resource group ${var.resource_group_name} is not in the region ${var.region}"
    }

    precondition {
      condition = contains(split(",",data.azurerm_app_configuration_key.cidr_list.value), var.vnet_address_space)
    }
  }
}
```

Now we've got two checks in place! But what about the post-conditions? Let's dig into those now.

### Post-conditions

As implied by the name, post-conditions are checked after a resource or data source is created or evaluated. Outputs cannot be used with the post-condition block. With resources, the post-condition will be evaluated after an apply is completed for that resource. Data sources are read during plan, so the post-condition will be evaluated during plan if all of the attributes referenced in the conditional argument are known, otherwise it will be evaluated during apply.

Because post-conditions are dealing with a resource or data source that has already been created or read, you can reference attributes of the object in the conditional argument using the `self` expression. The post-condition can be thought of as a guarantee that you're making about a particular object. If the guarantee is broken, then Terraform will halt the plan or apply process in its tracks and dependent resources will not be altered.

Why don't we continue our previous example by adding a post-condition block?

#### Post-Condition Example

We've already verified that the virtual network we're creating is in the same region as the resource group and is using a valid CIDR address space. But what if we also want to make sure we're deploying to the correct environment based on tagging? We can use a post-condition to make sure the environment tag is set to the correct value.

```terraform
data "azurerm_resource_group" "main" {
  name = var.resource_group_name

  lifecycle {
    postcondition {
      condition     = length(self.tags) > 0 && contains(keys(self.tags), "Environment")
      error_message = "The resource group ${var.resource_group_name} does not have an Environment tag."
    }

    postcondition {
      condition     = self.tags["Environment"] == var.environment_tag
      error_message = "The resource group ${var.resource_group_name} does not have the correct Environment tag."
    }
  }
}
```

The first `postcondition` block verifies that the `Environment` tag exists. If it doesn't the error we get back wouldn't be nearly as helpful to the person using the code:

```bash
Error: Invalid index
│
│   on main.tf line 28, in data "azurerm_resource_group" "main":
│   28:       condition = self.tags["Environment"] == var.environment_tag
│     ├────────────────
│     │ self.tags is empty map of string
│
│ The given key does not identify an element in this collection value.
```

To help out the user, we first check for the existence of the Environment tag before we check the value inside and provide a helpful error message if the tag is missing.

The second post-condition checks to make sure the Environment tag matches the value we were given as input. If it doesn't, we will get an error. Assuming you had a policy in place to create all resources with an Environment tag, this could be extremely useful and prevent the accidental deployment of resources into the wrong environment and region.

## Conclusion

These are two relatively simple examples of using pre and post conditions, but I hope they help to illustrate how the blocks work and how they could make your Terraform code more reliable and assist with module development.

Are you using `precondition` and `postcondition` blocks? If so, how? Let me know in the comments below.