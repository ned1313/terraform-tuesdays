# Moved Block Update for Terraform 1.3

Hey, remember that cool video and post I wrote about using the `moved` block in Terraform 1.1? Well, if not, I guess you could go read/watch that first, but I'll give you a quick recap here.

The `moved` block signals to Terraform that an existing resource has changed it's address within the Terraform configuration. This is useful when you want to rename a resource, or move it to a different module. Once you add a `moved` block to the configuration and make the actual resource change, Terraform will detect that the resource has moved, and will automatically migrate the state entry to the new address.

Previously, you would have made the resource change in your configuration and then run `terraform state mv` to update the state data to match. Now we're mixing declarative and imperative operations and probably stepping outside of the existing automation pipeline. That's not great.

## Improvements to the `moved` block

In the Terraform 1.1 version of the `moved` block, you could move a resource to a different address in a root module or a child module stored in a subdirectory. What you couldn't do is move a resource to a module sourced from an external location, like the Terraform public registry or a private registry. If you tried to do that, you would get an error like this:

```bash
│ Error: Cross-package move statement
│
│   on main.tf line 65:
│   65: moved {
│
│ This statement declares a move to an object declared in external module package "registry.terraform.io/terraform-aws-modules/vpc/aws". Move statements can be only within a single module package.
```

This limited the `moved` block to refactoring existing modules, but not leveraging modules from external sources. And that made me sad. The release of Terraform 1.3 has fixed this issue, and now you can move resources to modules sourced from external locations.

## Moving a resource to a module from the Terraform public registry

Why don't we start with an example. Here is a snippet of a Terraform configuration that creates a VPC and some additional resources.

```terraform
resource "aws_vpc" "vpc" {}

resource "aws_internet_gateway" "igw" {}

resource "aws_subnet" "subnet" {}

resource "aws_route" "default_route" {}

resource "aws_route_table" "public" {}

resource "aws_route_table_association" "public" {}
```

I've deployed this configuration to my AWS account before I knew about the robust VPC module that exists on the Terraform registry. Now I want to use that module in my code. I can do that by updating my configuration to include the module and add `moved` blocks for the existing resources.

```terraform
module "main" {
  source = "terraform-aws-modules/vpc/aws"
}

moved {
  from = aws_vpc.vpc
  to   = module.main.aws_vpc.this[0]
}

moved {
  from = aws_internet_gateway.igw
  to   = module.main.aws_internet_gateway.this[0]
}

moved {
  from = aws_subnet.subnet
  to   = module.main.aws_subnet.public[0]
}

moved {
  from = aws_route.default_route
  to   = module.main.aws_route.public_internet_gateway[0]
}

moved {
  from = aws_route_table.public
  to   = module.main.aws_route_table.public[0]
}

moved {
  from = aws_route_table_association.public
  to   = module.main.aws_route_table_association.public[0]
}
```

Since I've added a module, I'll need to run `terraform init` to download the module. Then I can run `terraform plan` to see what changes will be made.

```bash
Terraform will perform the following actions:

  # module.main.aws_internet_gateway.this[0] will be updated in-place
  # (moved from aws_internet_gateway.igw)


  # aws_route.default_route has moved to module.main.aws_route.public_internet_gateway[0]


  # module.main.aws_route_table.public[0] will be updated in-place
  # (moved from aws_route_table.public)


  # aws_route_table_association.public has moved to module.main.aws_route_table_association.public[0]


  # module.main.aws_subnet.public[0] will be updated in-place
  # (moved from aws_subnet.subnet)

  # aws_vpc.vpc has moved to module.main.aws_vpc.this[0]


Plan: 0 to add, 3 to change, 0 to destroy.
```

Terraform recognizes that I'm moving my existing resources to the new module, and it will automatically migrate the state data to the new address. This is great, because I don't have to manually update the state data with `terraform state mv`. I can just run `terraform apply` and Terraform will do the work for me.

Why are there changes you might ask? That's because the module I'm using has `Name` tags for the subnet, route table, and internet gateway. I didn't have those tags in my original configuration, so Terraform will add them.

The same process will work when moving the resources to a module sourced from a private registry or other external location.

## What's happening and what's supported?

Under the hood Terraform is following a simple process. But you need to know a little about how Terraform actually generates an execution plan for this to make sense. When you run `terraform plan`, Terraform loads a copy of state data into memory. Once you've added moved blocks to your configuration, Terraform will update the state data in memory to match the new addresses. Then it will generate a plan based on the updated state data. That is why you are seeing the text:

```bash
  # module.main.aws_subnet.public[0] will be updated in-place
  # (moved from aws_subnet.subnet)

  # aws_vpc.vpc has moved to module.main.aws_vpc.this[0]
```

With the new capabilities in Terraform 1.3 the following scenarios are supported:

* Rename a resource within a module
* Enabling `count` or `for_each` on a resource
* Renaming a module
* Enabling `count` or `for_each` on a module
* Splitting an existing module into multiple modules
* Moving a resource into a child module (local or externally sourced)
