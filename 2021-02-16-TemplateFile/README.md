# Using the `templatefile` function instead of the `template_file` data source

When I was working on the Boundary deployment for Azure using Terraform, I noticed that the AWS implementation was using the `templatefile` function instead of the the `template_file` data source. I wondered why, and when I went to the official Terraform docs for `template_file`, I saw the following:

> In Terraform 0.12 and later, the `templatefile` function offers a built-in mechanism for rendering a template from a file. Use that function instead, unless you are using Terraform 0.11 or earlier.

There appear to be two primary benefits of using the function instead of the data source.

1. The function is built into the Terraform binary, so it always matches the version of Terraform you are using. There is no need to get a plug-in, unlike the `template_file` data source, which uses the `template` provider plug-in.
1. The function can deal with complex data types, not just primitives. You can pass a set, list, map, etc. to `templatefile` as a value for a `var`, and it can interpolate it. The `template_file` data source can only accept strings, numbers, and boolean values.

Of course with the improvements in Terraform 0.12+, the need to use a template file has been reduced. You can now do much of what you did with template files directly in the configuration with stuff like `for_each` loops, `for` loops, and direct interpolation. The primary reason to use a template file is to improve the readability of the Terraform configuration file, and perhaps make reusable components. That's especially true when you're creating a `cloud-init` or `custom_data` file to be used with a VM deployment.

The rendering speed of `templatefile` and direct interpolation is markedly faster than using the data source. Terraform doesn't have to invoke a plugin or refresh the state of a data source. Even in this simple example, the difference is noticeable. If you are using a lot of templates, you could significantly reduce processing time by removing the `template_file` data source from all of your configurations.