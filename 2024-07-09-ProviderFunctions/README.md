# Using Provider Defined Functions in Terraform

Have you ever wished there were custom functions in Terraform? Well now there are! Sort of. Let me explain.

## Introduction

Whenever I am delivering a course on Terraform and we get to functions, someone inevitably asks if they can write their own custom functions. And that makes perfect sense. In a general purpose programming language, you can write your own methods and functions to help with reusability and consistency. It's the DRY mentality.

My answer, up until now, was no, you cannot write your own functions. If you want a new function in Terraform, you would have to try and get it added to the Terraform binary or you could write a module that does something similar to what the function should do. But now there's another option! With the release of Terraform 1.8, HashiCorp added provider defined functions. Let's dig in.

## Terraform Functions

All the functions in Terraform are built into the core binary. That means they are part of the compiled code and they execute super fast. If you wanted to write your own custom repeatable logic, you could do that with modules, but those are slower and don't have access to the full power of the Go programming language.

But there's another set of binaries that do use Go and are compiled, and those are provider plugins. So why not allow those to define functions too? That's exactly what provider defined functions are.

## Provider Function Syntax

As I just mentioned, provider defined functions are written and compiled as part of the provider plugin. The syntax might look a little funky, but it makes sense. You need to tell Terraform which plugin the function is coming from, so it starts with the provider keyword and two colons, then the provider name, followed by two colons, then the function name with a set of parentheses. Just like a built-in function, the arguments go inside the parentheses.

For example, the AWS provider has a function called arn_parse that breaks up an ARN into its constituent pieces. It's something you could have done with a combination of other functions or a dedicated module, but this is way easier and possibly better than whatever you may have written in the past.

The function takes a single arn as an argument and returns a map with keys for each component like partition, service, and account_id. In fact, why don't we see this and a few other provider functions in action.

## Using Provider Functions

Here's a configuration I've put together that creates an AWS VPC. My VPC has an ARN that I can retrieve and parse. Just like regular functions, I can try out the provider defined functions from the console.

I'll run terraform console and from within the console I'll run provider::aws::arn_parse(aws_vpc.my_vpc.arn). And I get back the ARN broken up like I would want.

I can take that same expression and use it to build a policy that references a partial arn.

HashiCorp has also added some functions into the built-in terraform provider, specifically: `encode_tfvars`, `decode_tfvars`, and `encode_expr`. You can read more about [them in the documentation](https://developer.hashicorp.com/terraform/language/functions/terraform-encode_tfvars), but they're for fairly uncommon situations and some of them can be replaced with the built-in `templatestring` function.

As a quick aside, I happened to notice that core functions that are part of the binary can now be referenced using their extended name, core::function_name. Not sure how long that's been the case, but if I run core::max(1,3,5) at the console, it renders properly. Not super important, but neat!

I want to mention here that if you plan to use provider defined functions, you're going to want to set a lower bound for the provider plugins and Terraform version you're using. Older versions of the provider won't have the functions, and so Terraform will return an error. And earlier versions of Terraform won't have any idea what the provider-defined function syntax is.

In particular, if you're writing modules for others to consume, you want to make sure to specify the minimum provider versions and set the minimum Terraform version to 1.8 or newer.

## Finding Provider Functions

I started looking through the most popular providers on the registry and here's the providers that have some functions today: aws, google, kubernetes, local, and time. Right now, there's no easy way to discover functions outside of looking in a particular provider.

Which I guess is kind of the point. The functions are supposed to be something specific to the provider. The function `direxists` in the `local` provider checks to see if a directory exists. The function `rfc_3339_parse` in the `time` provider breaks apart an rfc 3339 timestamp. That alone is hugely useful and might actually belong in Terraform proper.

While I appreciate the addition of provider defined functions, I'm a little concerned over discoverability for generic utility functions. I would expect to find the arn parse function in the aws provider. I might not think to check the local provider for a function that checks for a directory's existence. I'd probably look at the built-in functions, find that it isn't there, and kludge something else together.

## Writing Your Own

On the topic of discoverability, I wouldn't be surprised to find a couple providers spring up that are purely for functions. In fact, you could write your own right now. Is that something you'd like to know how to do? Leave a comment and let me know. I've been learning Go and I think I could create a video on writing a utility provider for Terraform that just has functions in it.

## Conclusion

Provider defined functions are a way for Terraform to support functions outside of what is baked into the core binary. This is an important step forward for Terraform and makes it easier for you to develop you own logic or leverage providers to bring additional functionality to Terraform.

That's gonna do it for today. Thanks for watching and until next time, keep calm and Terraform on.
