# Using Pre and Post Conditions in Terraform

## Introduction

When it comes to developing good code, you need to sanitize your input, check your assumptions and make guarantees that can be relied on by the next link in the chain. This is true for all code, including Terraform. With this video, I thought I would explore how the use of pre and post conditions can make your Terraform code more reliable and easier to maintain.

## Validation

The name of the game when it comes to verifying assertions and guarantees is validation. It all starts with the humble input variable, where you can use both the `type` and `validation` arguments to ensure that the input is of the correct type and value. I actually covered the validation argument in a previous video, so I won't into it now. Link is in the description and in the whosawasit thinger that appears above my noggin.

The upside is that you can catch validation issues early on, way before Terraform even has to load state data or draw its resource graph. When you're trying to iterate quickly, this is a huge benefit.

The downside of the validation block is that it is limited to only the variable value itself and anything you hardcode into the `condition` argument. You can check to see if a VM size is in a list of values, but that list needs to be hardcoded into the config. You can make sure a CIDR address is valid, but you can't grab a list of CIDR ranges from a data source to make sure it isn't being used.

The reason is because of when Terraform does the validation process in its workflow. The validation happens before the resource graph is drawn or the data sources are refreshed, so you can't reference anything in state or data sources within the validation block.

The answer to this is to use pre and post conditions.

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

### Pre-conditions

Pre-conditions run before the object its associated with is evaluated. You can use a pre-condition on a resource, data source or output. Since the pre-condition is running before the object is evaluated that means two important things:

* You can't reference the object itself or its attributes in the pre-condition
* Terraform will fail on a pre-condition before it fails on an invalid object argument or value

The first point means you can't use the `self` expression to refer to attributes of the object you're running the pre-condition check on. The second point means that if you have a bad value for the object, but the pre-condition fails, Terraform will only error on the pre-condition. It won't tell you about the bad value until you fix the pre-condition.

Pre-conditions can be thought of as assumptions that you're making about the state of the world before the object is evaluated. If the assumption is wrong, then the object can't be evaluated correctly. They also fail faster than the object itself, which can be a good thing if you're trying to iterate quickly.

Terraform will do its best to run pre-conditions during the execution plan generation, but if you're referring to attributes in the pre-condition that are not know until the apply phase, then the pre-condition will be run during the apply phase. For instance, if you're referring to the public IP address of an Azure VM in the pre-condition, that value isn't know until the public IP address is actually created, which happens during the apply phase.

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

Since the pre-condition can reference a data source, that means we have access to the `http` data source, which can be used to send a request to a URL. You might use that to check and make sure a service is ready before trying to provision a resource that depends on that service. You could also use it to grab a list of CIDR ranges from a URL and then check to make sure the CIDR range you were given as input is in that list.

```terraform