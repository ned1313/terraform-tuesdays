locals {
  # Load all of the data from json
  vnet_json_data = jsondecode(file("config_data.json")).VirtualNetworks

  network_subnets = flatten([
      for network_key, network in local.vnet_json_data : [
          for subnet in network.Subnets : {
              vnet = network_key
              subnet = subnet.Name
              cidr_block = cidrsubnet(network.AddressSpace, 8, subnet.Priority)
          }
      ]
  if network_key != "hub-vnet" ])
}

aws_bucket.my_buckets[0].name # bucket1
aws_bucket.my_buckets[*].name # ["bucket1", "bucket2","bucket3"]

    aws_subnet.main-subnet["subnet-1"].cidr_block

    [ for subnet in aws_subnet.main-subnet : subnet.cidr_block ]