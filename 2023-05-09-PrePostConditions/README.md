# Using Pre and Post Conditions in Terraform

## Introduction

When Terraform evaluates what infrastructure to deploy, it builds a dependency graph based on the contents and references in your configuration. The resultant graph is used to determine the order in which resources are created, updated, and destroyed. The way the graph is built depends heavily on references in the configuration between resources. For instance, let's say you have a configuration with an network interface and virtual machine.

```terraform
resource "azurerm_network_interface" "taco_svc" {
    ...
}

resource "azurerm_linux_virtual_machine" "taco_svc" {
    network_interface_ids = [azurerm_network_interface.taco_svc.id]
}
```

The `network_interface_ids` argument value refers to the `id` attribute of the `azurerm_network_interface` resource. The attribute value is unknown before the network interface is created, so Terraform knows it must create the network interface first, and then the virtual machine. This is a simple example, but the same concept applies to more complex configurations with many resources.

There are times when the dependency graph built from references is not enough, for instance you might have one resource that is dependent on another without a reference between them. Or you might have a situation where a resource is not ready right away for the next resource to use it. Or you might have a check you need to perform before a resource is created. For these types of cases, Terraform has meta-arguments to help you control the flow of the dependency graph and the order of the execution plan.

The most commonly used meta-argument is `depends_on` which takes a list of resources that the current resource must wait on before it can be created, and also lets Terraform know it needs to destroy the current resource first before destroying the resources in the list.

Two new meta-arguments that help you define provisioning flow were introduced in Terraform 1.2, they are the 

## Pre-Conditions

### Common Use Cases

## Post-Conditions

### Common Use Cases

## Conclusion