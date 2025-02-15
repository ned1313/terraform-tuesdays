# Data Transformation with Terraform

The information you're passed as inputs or from other data sources may take tons of different formats. As a Terraform operators, its your job to take the data as presented, make sure it's valid, and transform it as needed before passing it along for resource creation. In this video, we're going to dig into the process of data transformation using common input formats like YAML, JSON, and CSV and how to use for expressions, functions, and ternary operators to transform that data into a usable form.

## Data Transformation Basics

The first thing to keep in mind is that Terraform is declarative in nature, and so are its constructs. For expressions transform existing values, but they don't do so in a procedural way. If you're used to bash scripting or PowerShelling with do/while and for loops, using the `for` expression will take some getting used to.

I find the best way to deal with declarative expressions is to think of them as queries. In a procedural context, I might write something like:

```powershell
for($subnet in $subnets){
    if(!$subnet.isPublic){
        Set-AzVirtualNetworkSubnetConfig -Name $subnet.Name -VirtualNetwork $virtualNetwork -InputObject $natGateway
    }
  }
}
```

With Terraform, I need to query for a list of subnets that are private, and then use that list to create a NAT Gateway association:

```hcl
locals {
    private_subnets = { for k,v in var.subnets : k => v if v.is_public != true}
}

resource "azurerm_subnet" "private" {
    for_each             = local.private_subnets
    name                 = each.key
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = each.value.address_prefixes
}

resource "azurerm_subnet_nat_gateway_association" "private" {
    for_each       = local.private_subnets
    subnet_id      = azurerm_subnet[each.key].private.id
    nat_gateway_id = azurerm_nat_gateway.main.id
}
```

The contents of my `var.subnet` could be something like:

```hcl
{
    web = {
        address_prefixes = ["10.0.0.0/24"]
        is_public        = true
    },
    app = {
        address_prefixes = ["10.0.1.0/24"]
        is_public        = false
    },
    db = {
        address_prefixes = ["10.0.2.0/24"]
        is_public        = false
    }
}
```

The `for` expression is not looping through the construct, it is querying it and doing a data transformation on each record returned. The `if` statement at the end returns two records and I'm am asking for a new data structure composed of the key and value of the two records. It's like a mini-ETL!

## Functions and Syntax to Know

With that in mind, let's review some syntax and functions you're going to want to know from Terraform's implementation of HCL. For syntax, you will want to know how to use `for` expressions and conditional expressions.

### Syntax

Now I've done a whole video on for expressions, which I'll link up in the doobly-do. But the quick, quick version is this. For expressions transform one complex data structure to another. The input can be any collection or structural data type. That includes lists, tuples, sets, maps, and objects. The output of a for expression can either be a tuple or an object. If you're a little fuzzy on data structures, I've got a Terraform Basics video that covers those. I'm going to assume for this video that you already understand them.

A for expression is enclosed with symbols that signify which data structure you want as output, square brackets for a tuple and braces for an object. Inside the for expression you need a local variable to refer to the current item you're iterating over. If the input data is a list, tuple, or set, you only need one local variable. If it's a map or object, you'll need two, one for the key and one for the value.

So our for expression `{ for k,v in var.subnets : k => v if v.is_public != true}` is iterating over an object, and so we have our local variables k and v for the key and value respectively. You can use whatever name you want for the local variables. I recommend keeping it short and simple. If you find you need to nest for expressions, the local variables for the nested expression need to have different names than the containing expression. We'll get to nesting shortly.

The output is constructed by the expression after the colon. If you're constructing a tuple, you simply need a value. If you're constructing an object, you'll need a unique key followed by the assignment syntax of equals and greater than, which looks like an arrow. After that, it should be the value you're assigning to the key. In our example, we're assigning the existing value exactly, but only if the property is_public is not true.

The if statement comes after the value assignment expression.

There's one more syntax item that is probably not going to be on the exam, but it's actually pretty useful. Let's say you have multiple values you want to assign to a single key. Like if we had this structure for firewall rules:

```hcl
local {
    firewall_rules = {
        http = {
            port = 8080
            protocol = "TCP"
            direction = "inbound"
            permission = "allow"
        },
        https = {
            port = 8080
            protocol = "TCP"
            direction = "inbound"
            permission = "allow"
        },
        ssh = {
            port = 22
            protocol = "TCP"
            direction = "inbound"
            permission = "deny"
        },
        dns = {
            port = 53
            protocol = "UDP"
            direction = "outbound"
            permission = "allow"
        },
        update = {
            port = 8443
            protocol = "TCP"
            direction = "outbound"
            permission = "allow"
        }
    }
}
```

What if I want two lists, one for inbound and one for outbound?

This syntax will do exactly that:

```hcl
{ for name, rule in local.firewall_rules : rule.direction => name... }
```

I'll get back the following:

```hcl
{
  "inbound" = [
    "http",
    "https",
    "ssh",
  ]
  "outbound" = [
    "dns",
    "update",
  ]
}
```

When I need to create my firewall rules, I can iterate over each of these lists and grab the relevant rules from the `firewalls_rule` map. Pretty cool!

Ternary syntax is much simpler. The general form is CONDITION ? VALUE_IF_TRUE : VALUE_IF_FALSE. The condition expression must evaluate to `true` or `false`. You can also chain ternary statements like so: CONDITION ? VALUE_IF_TRUE : CONDITION ? VALUE_IF_TRUE : VALUE_IF_FALSE

I don't recommend chaining too many values, otherwise the code quickly becomes unreadable.

### Functions

Terraform has a ton of useful functions for transforming data. I'm just going to hit a few highlights, but I encourage you to play around with all of the functions listed in the collection, string, and type conversion categories:

Here's some highlights:

From string:

* `join` lets you create a single string from all the elements in a specified list of strings using the selected separator
* `regex` returns matches to a regular expression, can be combined with the can function to return a true or false result
* `split` kinda the opposite of `join` it takes a string and splits it into a list using the selected separator

From collections:

* `coalesce` returns the first argument that isn't empty, can be used with lists if you add the expansion dots at the end
* `compact` removes any null or empty values from a list
* `concat` combines multiple lists into a single list
* `distinct` removes any duplicate values in a list
* `flatten` takes nested lists and flattens the values to a single level list
* `lookup` finds the value of a given key in a map, with an option to return a default value if the key isn't found

From encoding:

* `yamldecode` - convert YAML data into an HCL data structure
* `jsondecode` - convert JSON data into an HCL data structure
* `csvdecode` - convert CSV data into an HCL data structure

From type conversion:

* `can` returns false if the nested expression returns an error, returns true otherwise, useful for validation and conditional expressions
* `try` takes a list of arguments and returns the first one that doesn't result in an error, useful for working with complex data structures where the structure is NOT well defined or values might be absent.

Like I said, this isn't an exhaustive list. You will have access to the Terraform documentation during the exam, but if you don't even know where to look, that won't really help you. Focus on the purpose behind the function and not its exact syntax. You can always look that up during the exam.

### Terraform Console

The console is going to be your best friend when evaluating expressions. Console has access to your current state, input variable values, and local values in the config. You can rapidly iterate on an expression until it returns the desired result. Get comfortable with the console!

## Challenges

Okay, so I am going to walk through the CSV example here, and leave the rest as an exercise for you.

In the CSV directory I have two CSV files. The first is simply server data and the other is more complicated firewall rules.

Our first challenge is to parse the server data and produce a map of the server name to the server type.

To load the data from the data.csv file, I'll use the file function nested inside the csvdecode function, and store that information in the local value csv_data.

Let's test that out in the console.

Looks like I get a list, but I want to produce a map. Maps are easier to use with a foreach argument if I'm going to create EC2 instances with this data.

It looks like our server names are unique, so I can use that as the map key. For the value, I could store the whole list entry or just the type. Let's try both: `{ for server in local.csv_data : server.name => server }`

I'm not actually going to create those instances, so I'll just leave it as an output.

For the next challenge, we need to take our firewall rules and create security groups for each system. This is going to be challenging!

Let's look at what we're given in the csv.

Each rule does reference which system it's for and which direction the rule is pointed at. Okay now what do we need to create using the AWS resources.

I've already included the necessary resource blocks. We're going to need an aws_security_group for each system. And then ingress and egress rules.

So what information do I need out of the CSV data? Well, I need a list of system names for the security group. Then I need a list of firewall rules that are inbound and a another list for outbound.

We're going to use for_each to create the groups and rules, which needs a set of strings or an object. For the groups, I can use a set of strings with the system names.

For the rules, I'll need to create an object from the list of rules. It looks like the rule IDs are unique, so that can be the key.

Okay, first we'll get the system names. Which I'll do by creating a local called systems and using a for expression to get a list of just the system property from every rule. Then I can nest that in a distinct function to return the unique values only.

In the security group, I'll use the toset function to convert the local value to a set.

Cool, that should do it for the security group. Now for the ingress rules. First, I need to convert the list of rules into an object, so I'll do that and use the Rule ID field as the key for the object and the rule itself as the value. Then I'll use the if expression to filter the results where the rule.direction is Inbound.

I still have to populate the rest of the arguments, and here's where things can get a little hairy. Security group id we can find by referencing the security group by system name.

Next up is the CIDR IPv4 argument, which corresponds to the source IP.

The from port is the starting port, and here's where we run into some trouble. Some of the port range entries have a single port and some have a range. This is absolutely the kind of crap you'll get from other systems and you have to deal with it.

The from port is easy, we can simply split on the dash and take the first element. Even if there's no dash, it will still return the first element.

But the to port? We have to deal with both scenarios. If it's a range, we need to use the value after the dash. If it's not a range, we can just use the from value. There's a few ways to handle this, but the easiest is probably the `try` function.

Try will return the first successful argument in the list you provide. So the first argument will split the port range string and return the second element. If there's not second element, an error will be thrown and try will move on to the next expression. For the second expression, we'll split the port range string and return the first element. Boom! We've dealt with the weirdness in our data.

The ip_protocol is a simple reference to the protocol in the rule.

That will do it for the ingress rules. You can rinse and repeat for the egress rules, just changing the filter on the rule direction to Outbound.