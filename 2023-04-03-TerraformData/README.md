# Introducing the Terraform Data Resource Type

The release of Terraform 1.4 introduced a few new things. The two I'm most excited about are the addition of the `-or-create` flag for `terraform workspace select` and the new `terraform_data` managed resource type.

## The `-or-create` flag

The new argument in `terraform workspace select` solves a common problem that many of you have probably already solved with a simple bash script. It stems back to the need to create a workspace if it doesn't exist when running a pipeline.

If you try to select a workspace in Terraform that doesn't exist, then you will get back an error. If you try to create a workspace that already exists, you will also get back an error. So you probably have a script that tries to select a workspace and if Terraform throws an error, you create the workspace. The `-or-create` flag solves this problem by creating the workspace if it doesn't exist.

## The `terraform_data` resource type

Of more interest to me, and the reason for this post/video is to explore the new `terraform_data` resource type. The primary goal behind the resource type is to replace the `null_resource` and its associated provider. But it also allows you to store arbitrary data in the state. Why try to replace the null provider? A little history is in order.

## The `null` provider

The `null` provider basically exists to orchestrate workflows in Terraform that would be difficult to achieve otherwise. The only resource is the `null_resource` and it is "created" when its `triggers` argument changes. The `triggers` argument is a map of values usually composed of attributes from other resources in the configuration. If the values change, then the resource is created or recreated. Within the resource, you would typically add provisioners to run scripts or commands.

There is also a `null_data_source` that was used to store and transform intermediate values. This data source has been replaced by the functionality of `local` values in a configuration.

## Terraform providers

For those of you who don't know or haven't given it much thought, providers in Terraform are separately managed and maintained executables that the core Terraform binary calls upon to perform the work of managing resources and data sources. When you initialize Terraform, part of what you're doing is downloading those providers from their source and storing them locally for Terraform to use. The `null` provider is amongst those providers.

This wasn't always the case. Way back in the old Terraform 0.9 days, all providers were bundled in with the core binary. When there were only a handleful of providers, that wasn't a problem. But as the number of providers grew, the situation becomes untenanble. The core binary was growing in size and everytime there was a provider update, a new version of Terraform had to be released. So the decision was made to split the providers out into their own executables.

The exception is the [built-in provider](https://developer.hashicorp.com/terraform/language/providers/requirements#built-in-providers). This provider is built into the core binary and versioned along with Terraform. As far I can tell, the only object in the provider before 1.4 was the `terraform_remote_state` data source. And now I guess we have the `terraform_data` resource.

When a provider is built into Terraform, that means two things. 1) It doesn't need to be downloaded from anywhere, you already have it. 2) The execution time of the provider will probably be faster because it isn't invoking an additional runtime. The `null` provider is not built-in, so it has to be downloaded and executed. There's also a third benefit to the maintainers of the `null` provider, in that they can stop maintaining a whole provider for a single resource. The same thing happened with the `template` provider once the `templatefile` function was added to Terraform.

## The `terraform_data` resource

This special little resource is meant to replace the `null_resource`. It takes two arguments detailed below:

* `triggers_replace` - A single value store in state data that will trigger a replacement of the resource if it changes. This is the equivalent of the `triggers` argument on the `null_resource`, but it is a generic value instead of a map of strings (which was always kind of silly).
* `input` - A single value to be stored in state data. It is also available as an `output` attribute.

Because both the `triggers_replace` and `input` argument take a generic value, you can store any valid data structure you want. It doesn't need to be a simple value like a string or number. You can store a list, map, or even a complex object. Not sure how useful that is, but it opens the door to possibilities.

### Replacing the `null_resource`

As I just mentioned, the `triggers_replace` argument is the functional equivalent of the `triggers` argument in a `null_resource`. If you're using the `null_resource` today with provisioners, then you can pretty much swap out for the `terraform_data` resource and move your provisioners over. For example:

```terraform
# Current null_resource
resource "null_resource" "example" {
  triggers = {
    other_resource = module.other_resource.id
  }

  provisioner "local-exec" {
    command = "echo ${module.other_resource.id}"
  }
}
```

```terraform
# Equivalent terraform_data resource
resource "terraform_data" {
    triggers_replace = module.other_resource.id

    provisioner "local-exec" {
    command = "echo ${module.other_resource.id}"
  }
}
```

Easy-peasy. Of course, now you're not limited to using a map of strings for the trigger. You can use any valid value you'd like. As long as something in that value changes, it will trigger the provisioners to run.

### The `input` argument

The `input` argument is a little different. It simply stores an arbitrary chunk of data in state. Changing the value you submit to the `input` argument will cause an update to the resource, not a replacement. Provisioners only run on create, recreate, or destroy, so changing the `input` value won't trigger any provisioners.

What could you do with such a thing? I guess whatever you wanted to. The example they give in the official documentation is to trigger a resource replacement using the `lifecycle` block and `replace_triggered_by` argument. Typically, you would use this when another resource is replaced and that requires the current resource to be replace as well. Terraform can usually infer this type of thing using graph dependencies, but sometimes it can't.

```terraform
## This is directly from the docs

variable "revision" {
  default = 1
}

resource "terraform_data" "replacement" {
  input = var.revision
}

# This resource has no convenient attribute which forces replacement,
# but can now be replaced by any change to the revision variable value.
resource "example_database" "test" {
  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}

```

Looking at the code, you might wonder why you can't just use the input variable `revision` directly in the `replace_triggered_by` argument. The `replace_triggered_by` argument only accepts resource addresses as values, meaning that you can't submit a local value or input variable. The `terraform_data` resource is a way to get around that limitation.

## But why?

I don't know exactly why the Terraform core team chose to introduce the `terraform_data` managed resource, but I can hazard a few guesses. First, the uses of provisioners is heavily recommended against by HashiCorp. The null provider existed entirely to support provisioners, and I'm guess they didn't want to maintain that code base anymore. You can expect the null provider to go into archive mode soon.

The new `replace_triggered_by` lifecycle argument was introduced in Terraform 1.2. I'm guessing there were a bunch of people asking to use input variables or local values in that field. Basically, the `terraform_data` resource was a way to handle that request and also kill off the null provider.

Two birds, one apply.
