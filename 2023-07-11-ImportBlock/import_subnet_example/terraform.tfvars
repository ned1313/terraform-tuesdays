resource_group_name = "BurritoBarn"
vnet_name           = "BurritoBarn"
address_space       = ["10.0.0.0/16"]
subnets = {
  web1 = "10.0.0.0/24"
  web2 = "10.0.1.0/24"
  web3 = "10.0.2.0/24"
}