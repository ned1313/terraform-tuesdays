# Providers
Providers explored for fun and *profit*.

## Provider basics

This one is all about Terraform providers. Where do they reside and where are they retrieved from? Let's start with how you specify a provider.

You can specify a provider implicitly, explicitly, and bound it by version. Check out the three example folders I have set up.

But wait, there's more!

## Provider registries

You can use the public registry for Terraform and have done with it. There's a ton of providers there and it's pretty easy to reference them. You simply add the full provider's source address, like `registry.terraform.io/hashicorp/azurerm`. Oh course if you're using `registry.terraform.io` you don't actually need to specify that part. 

You can host your own private registry by setting up one according to the [*provider registry protocol*](https://www.terraform.io/docs/internals/provider-registry-protocol.html). I'm not going to go into too much detail, but basically the provider should be found at an address composed of `hostname/namespace/type`.  If you're implementing this sucker, there is a laundry list of operations you need to support, like listing available versions and finding a provider package. It's fun!

This is only if you wanted to host your own private registry. If you're simply trying to keep a local copy, you've got options.

1. Configure `provider_installation` settings in your CLI configuration block
  1. Filesystem mirror - A local mirror holding copies of your plugins. You provide the path and what domains to include and exclude.
  1. Network mirror - Kind of the same as the local filesystem mirror, but on the network using HTTPS
  1. Direct - Pulls the information from the normal remote registry. You provider include and exclude.
1. Implied local mirror - Terraform sets a local file mirror based on the operating system you are using automatically. It doesn't populate those directories, but it will use what it finds there.
1. Cache - the optional plugin cache is set by adding a `plugin_cache_dir` setting in the CLI config file. Once you've configured it and run `terraform init`, the files will be copied to the cache location. Terraform will try to use symlinks to prevent multiple instances of a file.
1. Plugin directory - You can manually specify a plugin directory during initialization. This overrides everything and it probably a bad idea. Don't do this.
