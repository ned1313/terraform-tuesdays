# Let's get it started in here...
terraform init

# Now console it up!
terraform console

# Let's start exploring things with a for loop on our network key
[ for network_key, network in local.vnet_json_data : network_key if network_key != "hub-vnet" ]

[ for network_key, network in local.vnet_json_data : network.Subnets if network_key != "hub-vnet" ]

# Cool, cool, cool. We've got the networks we want
# Now I would like to get a list subnets as maps that include
# the subnet name, vnet name, and cidr range based on priority

# Let's start with just the inner loop of the subnet list we have
local.vnet_json_data.k8s-vnet.Subnets

# Get just the names
[ for subnet in local.vnet_json_data.k8s-vnet.Subnets : subnet.Name ]

# Now let's try to create a map 
[ for subnet in local.vnet_json_data.k8s-vnet.Subnets : { name = subnet.Name } ]

# Okay, let's try adding the cidr address calculation
[ for subnet in local.vnet_json_data.k8s-vnet.Subnets : { name = subnet.Name, cidr_address = cidrsubnet("10.12.0.0/16", 8, subnet.Priority) } ]

# Awesome! Now what we want is to do a nested for loop and include the vnet Name
[ for network_key, network in local.vnet_json_data : [ for subnet in network.Subnets : { name = subnet.Name, cidr_address = cidrsubnet(network.AddressSpace, 8, subnet.Priority), vnet = network_key } ] if network_key != "hub-vnet" ]

# Hoo-boy! Now we're cooking with gas! But we've got a list of lists and that's no good
# We can use flatten to get a list of maps
flatten([ for network_key, network in local.vnet_json_data : [ for subnet in network.Subnets : { name = subnet.Name, cidr_address = cidrsubnet(network.AddressSpace, 8, subnet.Priority), vnet = network_key } ] if network_key != "hub-vnet" ])

