# Terraform Basics: Local Values

It's time for another Terraform Basics and this time we're looking at local values. If you're coming from the world of ARM templates, these are analogous to variables. There really isn't a similar object in CloudFormation templates, which is one of the reasons I find CF so damn frustrating. We could get into a whole conversation about how to generate CF using the AWS CDK, but that's a story for another time.

## Local Values Syntax

You can add a local value to your terraform configuration by specifying a `locals` block in your code.

```terraform
locals {
    key = value
    toppings = ["lettuce","cheese","salsa"]
}
```

In the block, you can specify any number of key/value pairs. The `locals` block is essentially a custom object you can reference throughout your configuration. The `locals` block can be repeated as many times as you want in any files that make up your root module. 

Local values can build upon one another, so you might have a standard prefix you'd like to construct for naming called `local.prefix`. You could use the `prefix` value for other local values as such:

```terraform
locals {
    prefix = "${var.naming_prefix}-${var.region}"
    vnet_name = "${local.prefix}-taconet"
}
```

You are not limited to just variables or other local values. Your local values can also reference resources and data sources in the configuration, as well as the output of child modules.


## Local Value Referral

Local values are referenced with the keyword `local` followed by the name of the local value key. For instance, if we have defined a local value called `toppings`, we can refer to it with the syntax `local.toppings`. If the value is a complex object, standard Terraform syntax applies. We can refer to an element in the toppings list with the expression `local.toppings[0]`. 

### Local Value Scope

Local values are only available within their module. They are not directly exposed to parent or child modules.

## Local Value Usage

Local values are used in the same way you might use variables in another programming language. They serve as a calculated temporary placeholder for a value that can be referenced throughout your code. A good example is setting default metadata tags for all resources in a configuration. You could set the tags on every single resources, but that would be arduous and difficult to change. By using a local value, you can make a change in a single place and update all resources that refer to the local value.

If you have a value that is likely to change in the future and is referred to multiple times in your configuration, then local values are your friend. There is a downside to overusing local values. They can make your code more difficult to parse and analyze, especially when you're working in a large configuration with multiple files and local values blocks sprinkled throughout the config.

### Usage Strategy

There are two approaches that I have seen when defining local values in your configuration. The first is to group them together in a single file to make it easy to find and manipulate them. This is probably the most common and successful approach. I have also seen locals blocks included in the file where their value is used. For instance, you might define locals for your networking in the same file as your virtual network and subnets. You could even combine both approaches to have globally used locals defined in a dedicated file, and resource specific locals defined in the file that includes the target resource types.

Regardless of which strategy you plan to choose, I'd recommend adding a `README` or comment block in your Terraform configuration that explains how you plan to use local values. This will help not only other developers, but also yourself when you come back to it in six months and have no recollection of what you did.

### Locals for Testing

Another great use for locals is teaming up with `terraform console` to test functions or expressions. The console will bring in the values of variables and locals into its context, and you can reference them freely. You've probably seen me use locals for exactly this purpose.

## Conclusion

That's it! There's not that much to local values. Are they immensely useful? Yes! Are they complicated? No!