# Using Meta-arguments in Terraform

The foundation of Terraform and HCL in general is the configuration block. Inside a block are arguments composed of an identifier and a value. In the case of a resource block, the acceptable arguments are defined by the resource type. For instance, an Azure Resource Group needs a location and name to be provisioned, so the `azurerm_resource_group` resource type requires the arguments `location` and `name`.

```hcl
resource "azurerm_resource_group" "example" {
    location = "West US"
    name     = "taco-wagon"
}
```

The required arguments can be tied back to the provider and the API it interacts with. In the case of the Azure Resource Group, the [API defines](https://learn.microsoft.com/en-us/rest/api/resources/resource-groups/create-or-update?view=rest-resources-2021-04-01&viewFallbackFrom=rest-resources-2022-12-01&tabs=HTTP) that the `name` must be included in the URI and the `location` must be specified in the request body.

However there are some arguments in Terraform that are not linked back to the provider and the platform it configures. These arguments provide Terraform with additional instructions on how to interpret the configuration or manage the lifecycle of objects. Such arguments are called **meta-arguments** in the same way that data about data is called metadata.

What are these meta-arguments and which ones are supported by different block types? That's what we'll dig into today.

## Meta-arguments Overview

As I just mentioned, meta-arguments are meant to tell Terraform how to manage or interpret the configuration of an object. The provider and platform are unaware of these arguments, as they are an internal implementation detail for Terraform. One example would be the `depends_on` argument, which is used to control the order in which objects are evaluated and instantiated by Terraform. The `depends_on` argument impacts the creation of the resource graph built by Terraform and influences the order or operations for an execution plan.

Another example would be the `count` argument, which allows you to create multiple instances of a resource or module in your configuration. The `count` argument is interpreted by Terraform when drawing the resource graph and creating an execution plan, but the provider and platform are completely unaware of its existence. All they know about is how many of a resource you want to create.

With that context in place, let's take a look at the most common meta-arguments and which block types support them.

## Depends On

As I just mentioned, the `depends_on` argument determines the order in which objects are evaluated and operated on. Typically, Terraform determines dependency based on reference in the code. For instance, in the following code our Virtual Network is referencing the Resource Group being created by the same configuration:

```hcl
resource "azurerm_resource_group" "example" {
    name     = "taco-wagon"
    location = "West US"
}

resource "azurerm_virtual_network" "example" {
    name                = "taco-net"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    ...
}
```

The reference to the Resource Group creates a dependency in the Terraform resource graph, leading Terraform to create the Resource Group before the Virtual Network. Likewise, if and when the deployment is destroyed, Terraform will destroy the Virtual Network before the Resource Group.

But what if there is no direct reference between two resources? How can you let Terraform know about a dependency explicitly? That is what the `depends_on` argument does. 