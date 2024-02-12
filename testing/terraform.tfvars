naming_prefix = "nsb"
common_tags = {
  Environment = "development"
}
vnet_address_space = ["10.42.0.0/16"]
subnet_configuration = {
  web = "10.42.0.0/24"
  app = "10.42.1.0/24"
}
nsg_security_rules = {
  http = {
    priority               = 100
    protocol               = "Tcp"
    destination_port_range = "80"
    direction              = "Inbound"
    access                 = "Allow"
  }

  https = {
    priority               = 110
    protocol               = "Tcp"
    destination_port_range = "443"
    direction              = "Inbound"
    access                 = "Allow"
  }

  icmp = {
    priority               = 120
    protocol               = "Icmp"
    destination_port_range = "*"
    direction              = "Inbound"
    access                 = "Allow"
  }
}