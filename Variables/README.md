# Variables in Terraform

This is part of the Terraform Basics path. In this video and demo, we are going to cover what Terraform input variables are and how you can use them. As a point of disambiguation, **Variables** and **Input Variables** are used interchangeably. For brevity, I am going to use the term variables, but it is safe to assume I am talking about input variables.

Variables define arguments for a Terraform module. You can pass values to a Terraform module using those arguments. The logistics of how you pass values will be covered later. Values are passed during a Terraform evaluation. Each time Terraform evaluates a configuration, values for each defined variable need to be supplied. Terraform does not store the values supplied for variables in the state data.

## Variable syntax

Variables are defined using the `variable` keyword followed by the name label for the variable and curly braces:

```terraform
variable "taco" {}
```

That is everything you need to supply for a basic variable, but there's probably a bit more you'd like to add. Let's enumerate the fields for a variable:

```terraform
variable "taco" {
    description = "" # A string describing the purpose of the variable
    type = string # A simple or complex data type for the variable, Terraform will attempt conversion
    default = "crunchy" # A default value for the variable if none is specified at runtime
}
```

There's two more fields which we will investigate in more detail shortly.

## Variable referral

How does one use a variable in their configuration? Quite simply. You will use the `var` keyword follow by a `.` and the name label for the variable. From the previous block, the value stored in our variable would be referenced by using the following syntax:

```terraform
var.taco
```

You do not need to use interpolation syntax unless you are trying to construct string. For instance:

```terraform
"Ned ate a ${var.taco} taco."
```

Would render to the string:

```bash
Ned ate a crunchy taco.
```

You may see interpolation syntax used heavily in older Terraform configurations where all references needed to use interpolation. Version 0.12 introduced HCL2 and removed the need for interpolation syntax when only the reference value is needed.

If you're using a non-primitive data type, then the whole value of the data type is returned. You can drill down to a specific value by using standard Terraform syntax.

## Variable scoping

The variables you define in a module are only available within the scope of that module. If you want to pass values to a child module, then you'll need to define variables inside that child module and pass the values stored in the variables of the parent module. If you want to pass variable values stored in a child module to the parent module, you should expose those values using outputs.

Likewise, you can pass values from one child module to another by defining the proper outputs in the first module and the proper variables in the second module. The parent module for both children is responsible for taking the outputs of the first module and passing them as inputs variables to the second module.

## Variable validation

Introduced in Terraform 0.14, you can now validate the value passed for a variable. This is accomplished through one or more `validation` blocks, the syntax of which is as follows:

```terraform
variable "taco" {

  validation {
      condition = true # Condition that evaluates to true or false
      error_message = "Error." # At least one full sentence describing the error
  }

}
```

You can have a bunch of validation rules, but I'd recommend not going overboard. Also, you can only refer to the variable being evaluated, not other variables or local values.

## Variable suppression

Sometimes the value stored in a variable is sensitive in nature. It could be a password, API key, or something similar. You can suppress the display of the value in the terminal and logs by using the sensitive argument.

```terraform
variable "taco" {
    sensitive = true
}
```

Terraform will treat the variable and any other expressions that use the variable as sensitive. That means if you construct a local value or pass the variable as a value to a resource, Terraform will treat that value is sensitive. Providers don't necessarily respect the sensitive designation, so they may expose the value through their logging or output. The major providers have been updating their code to respect sensitivity, but YMMV.

Setting a variable as sensitive may suppress it in the terminal and logs, but it's value will still be stored in Terraform state using plain-text. That's why the state data should be treated as sensitive and stored on an platform that supports encryption at rest and in transit.

## Supplying values

There are a LOT of options to supply values to a variable. Let's just list them out first:

* At the command line using `-var`
* At the command line using `-var-file` and a variables file
* With a `terraform.tfvars` or `terraform.tfvars.json` file
* With files ending in `.auto.tfvars` or `.auto.tfvars.json`
* Using environment variables starting with `TF_VAR_`

Which one should you choose? Well, there's a couple factors to take into account.

### Variable definition precedence

Terraform loads values for variables in the following order:

* Environment variables
* `terraform.tfvars` file
* `terraform.tfvars.json` file
* `auto.tfvars` or `auto.tfvars.json` files
* `-var` and `-var-file` options in the order specified

This means you could have a set of default values stored in a `terraform.tfvars` file and override them with a value specified with the `-var` option at the command line. The `terraform.tfvars` file could be your sane defaults for a given environment, instead of a having a default value in the configuration. Then you can override those values at runtime with a higher precedence option.

### Sensitive values

The second factor is whether or not the variable is sensitive. You might not want to write a sensitive value to the file system, so using a `.tfvars` or `.tfvars.json` file is out of the question. You could pass the value as an environment variable or specify it at the command line. Of course, if you specify it at the command line then it may show up in logs and that's not good either. 

The **best** option would be using a data source in your Terraform configuration to load sensitive values, but that's not always an option. That leaves us with environment variables. You can use the `TF_VAR_` syntax, but bear in mind that has the lowest precedence in the evaluation. You could also supply it at the command line using `-var` and the name of the environment variable. Ultimately, it's going to depend on your configuration and deployment architecture.