# Using the Moved Block in Terraform 1.1

The release of Terraform 1.1 has brought with it a new block type called `moved`. This is a super-cool new block that helps with when you want to refactor your Terraform code **without** breaking production.

Essentially, the idea is that you have an existing deployment using your Terraform code. Now you want to update the code to move some resources into a module or replace multiple resources with a for_each loop. That seems like a reasonable thing to do right?

You will quickly discover that Terraform doesn't understand the updated resource address for existing resources, and so it wants to destroy your existing resources and create new ones. That's not a problem when you're using an ephemeral environment, but it's markedly less awesome when you accidentally delete all subnets in production and respawn them.

The way to deal with this prior to the `moved` block was to use the command `terraform state mv` to move resources to a new location in the state file. As we all know, mucking around with the state file is *fraught with peril*. The introduction of the `moved` block let's you be more deliberate with resource address changes, and also let's you document changes in code for those who might be using your Terraform code as a module.

Why don't we ground this with some examples?

## Moving resources into a module

Let's say I have Terraform code that defines an AWS VPC, including a subnet, route, and internet gateway:

```terraform
resource "aws_vpc" "vpc" {}

resource "aws_subnet" "subnet" {}

resource "aws_route" "default_route" {}

resource "aws_internet_gateway" "igw" {}
```

I take the code and deploy it to my AWS account, and Terraform creates the infrastructure and saves the environment information in state data. The address for my VPC will be `aws_vpc.vpc` and it will map to the id of the VPC in my AWS account `vpc-12345`.

Now let's say I want to create a VPC module to handle the networking for this and other configurations. I can update my code to this:

```terraform
module "vpc" {
    source = "./vpc_module"
}
```

And move my networking resources to the module. But what happens when I want to apply this new code to my existing deployment? Running a Terraform plan tells me the following:

```bash
Plan: 4 to add, 0 to change, 4 to destroy.
```

**4 to destroy**?! That's not what I want! If I look at one of the resources being destroyed:

```bash
aws_vpc.vpc will be destroyed
```

As far as Terraform is concerned, my current VPC at the address `aws_subnet.vpc` was removed from the code, and so the corresponding VPC in AWS with the ID `vpc-12345` should also be removed.

In the resources being created, I can see:

```bash
module.vpc.aws_vpc.vpc will be created
```

The address for the VPC is now `module.vpc.aws_vpc.vpc`.  Terraform has no way of knowing that the VPC at address `module.vpc.aws_vpc.vpc` is the same as the one I removed and should be associated with `vpc-12345`.

### Using `terraform state mv`

Prior to Terraform 1.1, the way to deal with this problem was to use the `state mv` subcommand to update the state file with the correct mapping. For instance, we could run the following command:

```bash
terraform state mv aws_vpc.vpc module.vpc.aws_vpc.vpc
```

And now when Terraform runs a plan, it won't think any changes are necessary for the VPC. We would have to repeat the process for each of the four resources being destroyed to ensure nothing in our target environment is actually changed.

```bash
terraform state mv aws_subnet.subnet module.vpc.aws_subnet.subnets[0]
terraform state mv aws_internet_gateway.igw module.vpc.aws_internet_gateway.igw
terraform state mv aws_route.default_route module.vpc.aws_route.default_route
```

Now when I run a Terraform plan, I get the following output.

```bash
No changes. Your infrastructure matches the configuration.
```

Excellent! The process worked successfully. Unfortunately, the changes happened in an imperative way and are not documented by the code. That means if we were running this through an automation pipeline, we would have to make the state updates manually and *then* kick off the pipeline. That's *less* than ideal. Worse, if we were using workspaces, we'd have to repeat the process for every workspace.

Terraform 1.1 introduces a better way.

### Using a `moved` block

Instead of using the `state mv` commands, we can instead use the declarative `moved` block to express where our resources have moved to. In the code we can add the following blocks:

```terraform
moved {
    from = aws_vpc.vpc 
    to   = module.vpc.aws_vpc.vpc
}

moved {
    from = aws_internet_gateway.igw
    to   = module.vpc.aws_internet_gateway.igw
}

moved {
    from = aws_route.default_route
    to   = module.vpc.aws_route.default_route
}

moved {
    from = aws_subnet.subnet
    to   = module.vpc.aws_subnet.subnets[0]
}
```

If we add the above blocks and run `terraform plan`, we will get the following output:

```bash
Plan: 0 to add, 0 to change, 0 to destroy.
```

And for each resource we will see something like this:

```bash
aws_vpc.vpc has moved to module.vpc.aws_vpc.vpc
```

Peaking in the state data, the resources have not been updated yet.

```bash
$> terraform state list

data.aws_availability_zones.available
aws_internet_gateway.igw
aws_route.default_route
aws_subnet.subnet
aws_vpc.vpc
```

Terraform is simply letting us know what changes it will make on `apply`.

Running the `apply` will result in the following:

```bash
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

Sweet! And if we check our state data, we'll see that it has been updated.

```bash
$> terraform state list

data.aws_availability_zones.available
module.vpc.aws_internet_gateway.igw
module.vpc.aws_route.default_route
module.vpc.aws_subnet.subnets[0]
module.vpc.aws_vpc.vpc
```

We were able to refactor our code, keep everything declarative, and verify there was no impact to the target environment before applying the change. Because we kept it all in code, the process could be handled through our regular automation process instead of manually messing with state data. There is also a clear trail of what changes were made and when.

After the change has been applied, the `moved` blocks can be removed from code, or left it until the next refactor.

## Renaming a resource

The same process shown above can be used to simply rename a resource in a configuration. Let's say we have a resource like this:

```terraform
resource "aws_subnet" "subnet" {}
```

And we want to change the resource to create multiple subnets using the `count` meta-argument.

```terraform
locals {
    subnets = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
}

resource "aws_subnet" "subnets" {
    count = length(local.subnets)
}
```

Just like the previous example, we could use the `state mv` command to update our state data to change the address of the subnet from `aws_subnet.subnet` to `aws_subnet_subnets[0]`.

Or we could add a `moved` block like this:

```terraform
moved {
    from = aws_subnet.subnet
    to   = aws_subnet_subnets[0]
}
```

And accomplish the same goal without resorting to manual, imperative processes. Plus, we have a record of the change in case it impacts anything tied to our code.

## Important caveats!

The `moved` block doesn't solve all your problems. There are a few caveats to keep in mind.

### External module packages

Let's say that instead of moving our resources into a VPC module we wrote, instead we wanted to use the public VPC module from the Terraform registry. Unfortunately, that's a **no-go** for the `moved` block. Trying to do so will result in the following error:

```bash
│ Error: Cross-package move statement
│
│   on main.tf line 65:
│   65: moved {
│
│ This statement declares a move to an object declared in external module package "registry.terraform.io/terraform-aws-modules/vpc/aws". Move statements can be only within a single module package.
```

That's correct friends, `moved` is limited to refactoring for a single module package. You can move resources into child modules that reside in the same directory structure as the root module, but you can't move resources to a module in an external location. I'm guessing that might change with future releases, but it's an important point to bear in mind.

Why is this the case? I haven't heard this directly from HashiCorp, but I think it has to do with module refactoring. One of the main use cases for the `moved` block is refactoring modules available on a registry. I think there is concern that refactoring a module on a registry with `moved` blocks that point to different external module package could create too many weird dependencies.

If you plan to migrate to an external module package for resources in your code, you'll have to stick with `state mv` for now.

### Using `for_each` with a set

Another caveat is updating a resource block to use a `for_each` meta-argument with a set of strings. Let's consider the following:

```terraform
locals {
  subnet_cidr = "192.168.0.0/24"
}

resource "aws_subnet" "subnet" {
    cidr_block = local.subnet_cidr
}
```

What if you want to update the code to define the same subnet along with several others using a `for_each` loop and a map or subnets?

```terraform
locals {
    subnets = {
        subnet1 = "192.168.0.0/24"
        subnet2 = "192.168.1.0/24"
        subnet3 = "192.168.2.0/24"
    }
}

resource "aws_subnet" "subnet" {
    for_each = local.subnets
    cidr_block = each.value
}
```

Not a problem. You can easily add the `moved` block for the original subnet like this:

```terraform
moved {
    from = aws_subnet.subnet
    to = aws_subnet.subnet["subnet1"]
}
```

What if you wanted to use a list instead of a map for your values?

```terraform
locals {
    subnets = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
}

resource "aws_subnet" "subnet" {
    for_each = toset(local.subnets)
    cidr_block = each.value
}
```

Well, now we have a problem. The data type submitted to the `for_each` argument is a set, **not a list**, so we cannot refer to the resources created by an element index, i.e. `aws_subnet.subnet[0]` is not valid. What are we going to use in our `moved` block to refer to the original subnet?

The answer lies in what data type is created by a resource with a `for_each` meta-argument. The data type is a object, and the keys of the object are based on whether the data type submitted was a *set* or a *map*. If it's a map, the keys of the object are set to the keys of the map. If it's a set, the keys of the object are set to the values of the set.

Our `moved` block would look like this:

```terraform
moved {
    from = aws_subnet.subnet
    to   = aws_subnet.subnet["192.168.0.0/24"]
}
```

Problem solved.

> If you've ever wondered why the `for_each` meta-argument only accepts strings as the value in the set, **this** is why. Terraform uses those strings as keys in the object generated. If you tried to give it a set of maps or a set of lists, what would it use for the keys? It is also why the `for_each` uses a set and not a list for values. The set data type is by definition a collection of unique values. The `toset()` function will remove any duplicates in the list and return only the unique elements as a set.

## Wrap-up

The `moved` block is going to be hugely useful for situations where you want to refactor your code in a way that supports versioning and automation. It isn't going to solve every situation, like if you're moving to an external module package. For those cases, you can always use `terraform state mv` to manipulate the state data.

`moved` blocks also help tremendously when you are using workspaces for Terraform. Imagine the problem of using `state mv` for each workspace under management by Terraform, versus the simplicity of using a `moved` block in your code. I definitely prefer the latter.

Once you have added `moved` blocks to your code, you should leave them in place as long as anyone is running the older version of the code somewhere. I could see creating a `moved.tf` file in your code specifically to track the `moved` blocks. In addition, I'd recommend adding some comments, a date, and maybe even a code commit hash to know when each `moved` block was added and why.
