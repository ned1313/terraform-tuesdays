# Terraform Basics: Outputs

Behold! The humble output. What is the purpose behind an output? How does it fit in with the module-based structure of Terraform? How and why would you use an output? That's what I intend to cover in this Terraform Basics video and demo.

## Module-based Structure

Terraform follows a module-based structure, meaning that your configuration files live inside a module. The `.tf` files in your current working directory are considered the root module. Any modules invoked by your root module are child modules. I covered this in detail for the `2021-06-01-Modules` Terraform Basics demo. Information enters a module through the use of variables and data sources, and it exits the module through outputs. Allow me to repeat that:

> Outputs are how information leaves a module.

## Use Cases

There are three primary use cases for outputs: display information at the terminal window, make information available to parent modules, make information available to other configurations. Let's dig into each of these.

### Terminal Window

When you run a `terraform apply` the outputs defined in your root module are displayed in the terminal when the process completes. You can also display the current output values in Terraform state by running `terraform output`. The displayed output is human-oriented by default, but you can also ask for the output values to be represented with JSON or as raw strings. Doing so allows a separate program to ingest those outputs. For instance, you might have a web hook that takes the JSON formatted output from a completed Terraform run and kicks off some additional tasks.

### Parent Modules

Outputs are the way child modules can pass information back up to the parent module. The parent module does not have access to the local values inside a child module. As far as the parent module is concerned, the child module is a black box with input variables supplied by the parent modules and output values exposed to the parent module.

### Other Configurations

It is not uncommon to have one Terraform configuration use the state data of another configuration as a data source. Think about a network configuration that has been deployed. Other configurations may want to query the network configuration for information about subnets, firewalls, and security groups. This is done through the `terraform_remote_state` data source. The data source allows one configuration to access state data about another configuration with the caveat that only the outputs from the source configuration will be available. Input variables, local values, and resource attributes are all out of scope.

## Syntax

Now that we have a firm grounding into why you would use outputs, it's time to take a look at the syntax, and then we can dig into the three use cases.

Declaring an output is pretty darn easy, the basic format looks like this:

```terraform
output "name_of_output" {
    value = "value_of_output"
}
```

There's a caveat here. For reasons I don't understand, the name of the output cannot start with a number. This is actually true of all identifiers in Terraform. I discovered it with outputs because I was trying to control the order in which the outputs were printed on the screen. Terraform will print all outputs in alphabetical order, and I was trying to number them. The solution was to use letter prefixes instead, but still good information to know.

### The Value

The value can be any supported data structure type in Terraform. In the olden days of Terraform, the output data type could only be a string. Lists, maps, and objects were rendered as strings. If you wanted to pass an entire resource, including all of it's attributes, this was sub-optimal. Fortunately, now you can simply pass the resource itself as the value and the output will render properly.

### Additional Arguments

In addition to `value`, you can also include three other arguments:

* `description` - describes the intention of the output for someone consuming the module
* `sensitive` - sets the value as sensitive, so it will not be included in terraform logs or terminal output
* `depends_on` - a list of other objects in the configuration the output is dependent on

## Accessing Outputs

The way you access an output will depend on the use case. For the terminal window or script, it will be shown to you. Pretty simple.

You can access an output of a child module with the following syntax: `module.child_module_name.output_name`.

You can access an output from a remote state data source with the following syntax: `data.terraform_remote_state.name_label.outputs.output_name`.
