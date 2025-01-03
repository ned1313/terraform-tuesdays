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

