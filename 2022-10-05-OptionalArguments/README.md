# Optional Arguments

Well hot damn! Terraform 1.3 has introduced an incredibly popular feature for the Terraform community: optional arguments. This is a feature that has been requested for a long time, and it's finally here. Let's take a look at how it works.

## Type Constraints

Before we dig into optional arguments, it's probably important to address type constraints, you know the place where you would use them. For the casual Terraform user, you probably haven't written a lot of type constraints for input variables, so the need for optional arguments may not be immediately obvious. Let's take a look at an example input variable.

```hcl
variable "my_string_var" {}
```

This is all you need to define an input variable. You declare a variable block and give it a name. That's it. But what if you want to make sure that the value passed in is a string? You can use a type constraint to do that.

```hcl
variable "my_string_var" {
  type = string
}
```

Easy peasy. Now if you pass in a number, you'll get an error. But what if you want to make the variable optional? Every input variable needs a value at run time, so you do that by providing a default value.

```hcl
variable "my_string_var" {
  type    = string
  default = "Hello, Taco!"
}
```

That works really well for a basic string, but what if you are dealing with a more complicated data structure? You can use a type constraint to build out a complicated object with multiple arguments. Here's an example someone sent me recently via Twitter.

```hcl
variable "global_secondary_index_map" {
  type = list(object({
    hash_key           = string
    global_name        = string
    non_key_attributes = list(string)
    projection_type    = string
    range_key          = string
    read_capacity      = number
    write_capacity     = number
  }))
}
```

If someone wants to use that variable, they can't leave out any of the arguments. They have to provide a value for each one.

```hcl
global_secondary_index_map = [
  {
    hash_key           = "taco-id"
    global_name        = "chicken_taco"
    non_key_attributes = ["peppers"]
    projection_type    = "INCLUDE"
    range_key          = "meat"
    read_capacity      = 5
    write_capacity     = 5
  }
]
```

That's great if you want to make sure that the user provides values for all of the arguments, but what if you want to make some of them optional? That's where optional arguments come in.

## Optional Argument Usage

Optional arguments leverage the `optional` keyword to make arguments optional. Let's take a look at an example.

```hcl
variable "taco_object" {
  type = object({
    meat   = string
    cheese = optional(string, "cheddar")
    salsa  = optional(string)
  })
}
```

In this example, we are defining a variable that is an object with three arguments. The first one `meat` is required, but the other two are optional. The `meat` argument is a string, and the `cheese` argument is a string with a default value. The third argument (`salsa`) is a string with no default value.

The general syntax for an optional argument is `optional(type, default)`. The `type` is the type of the argument, and the `default` is the default value for the argument. If you don't provide a default value, the argument will be set to `null`.

I can submit the following values for the variable.

```hcl
taco_object = {
  meat   = "chicken"
  cheese = "jack"
}
```

And that will work just fine. Now the `salsa` argument has a null value, and I need to deal with that when I parse the variable. I can do that by using a conditional expression.

```hcl
locals {
    salsa = var.taco_object.salsa != null ? var.taco_object.salsa : "mild"
}
```

Which would set the value of `salsa` to `mild` if no value is present in the `taco_object.salsa` argument. If I didn't want a default value, I could leave the value set to `null`. When an argument is set to `null` for a resource or data source, it will not be included in the request. The provider will use the default value for that argument.

## Conclusion

The `optional` keyword is a great addition to Terraform. However, it's not the sort of thing you would care about if you are just consuming Terraform. The keyword shines as you develop modules for others to consume, providing flexibility for both the user and the developer. If you found yourself using the `any` type constraint to make arguments optional, you can now use the `optional` keyword instead.

*This post was partially written by GitHub Copilot. Initially I turned off Copilot for markdown files, but it actually does help flesh out a sentence quickly and comes up with code examples that are close enough to what I would write. Not bad Copilot, not bad indeed.*
