# What's new in Terraform 0.15?

This episode is going to be all about what is new in Terraform 0.15, or at least the things I am most interested in. If you're planning to follow along, you're going to have to update to Terraform 0.15.x. I *feel* like this should go without saying, which is exactly why I am saying it.

Let's dig in shall we? Here's the [CHANGELOG.](https://github.com/hashicorp/terraform/blob/v0.15.0/CHANGELOG.md)

## Deprecations

Okay, there has been much speculation that 0.15 is the last version before hitting the big 1.0. If we look at the laundry list of notes and breaking changes there is a common theme here. The theme is spring cleaning. It looks like the team wants to finalize a bunch of deprecated functionality and features that might potentially break something before a 1.0 release. 

One area of note are all the features that were deprecated in v0.12 through v0.14. Deprecated usually means that the feature will still work, but soon will be removed completely. Some of these changes are going to break old modules and configs - that's why they're called *breaking* changes. Of particular note are the following:

* `list` and `map` functions: these have long since been replaced with formal syntax, i.e. `[...]` and `{...}` respectively. If you still need to convert to a list or map type using a function, then check out `tolist` and `tomap`. This should be an easy fix.
* Variable types in quotes: Before formal type support, you would set the type using the syntax `type = "string"`. But now there is no need to use the quotes! And now it is not supported and will throw an error. This should be an easy fix.
* Built-in vendor provisioners (chef, puppet, etc.) have been removed: These were always a bit awkward and I don't know anyone who was using them. Now that HashiCorp considers provisioners *EVIL*, this cannot be a surprise. You can always use `local-exec` and `remote-exec` if you have to.
* `terraform init` retires lots of arguments: I count four different arguments that are no longer available. 
* `-force` on `destroy` is gone: Honestly, this was deprecated forever ago. You should be using `-auto-approve` and now you **have** to.

That's just some of the stuff. Seriously go read the CHANGELOG if you want to know more. It reads like a checklist of what they need to break before v1.0. 

# Enhancements

That's enough of what's broken. Let's talk about what's new and awesome. I can't get into everything, so let's hit my top five:

1. `configuration_aliases` in the `required_providers` entries
1. `terraform fmt` fixes unnecessary interpolation
1. `terraform validate` is more helpful
1. CLI is not using the old Windows console API anymore (*finally*)
1. Better reporting on plugin crashes
1. Separate logging for core and providers
1. AzureRM can use Azure AD users/roles

And lastly, I feel this was written specifically for me. Terraform will now suggest the correct command when you mistype a top-level command. The example they give is `terraform destory` would suggest `terraform destroy`, something I have done **countless** times.

# Experiments

Holy cow did HashiCorp bury the lede on this one. They are working on an in-language testing suite. Not terratest or other similar tools, but being able to actually write tests in HCL as part of your modules. This deserves it's own video, so I'm not going to get into it now. But it reminds me a lot of writing Pester tests for PowerShell.