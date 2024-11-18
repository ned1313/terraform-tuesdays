






resource "azurerm_subnet" "main" {
  count = 3
  #...
}



variable "subnet_count" {
    type    = number
    default = 3
}

resource "azurerm_subnet" "main" {
  count = var.subnet_count
  #...
}

locals {
  plain_string = "I'm a string!"
  single_quoted = 'I am single quoted' # ERROR!
}


locals {
  multi_line = <<EOF
Here is my multi-line string.
Share and enjoy! 🌮🌮🌮
EOF
}

resource "azurerm_linux_virtual_machine" "web" {
  #...
  user_data = <<EOF
#!/bin/bash
echo "Howdy friends! I'm ${var.machine_name}"
EOF
}

variable "create_nat_gateway" {
  type        = bool
  description = "Whether or not to create a NAT gateway"
  default     = false
}

resource "azure_subnet" "main" {
  #...

  tags = null
}

variable "common_tags" {
  type    = map(string)
  default = null
}

resource "azure_subnet" "main" {
  #...

  tags = var.common_tags
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

resource "azure_subnet" "main" {
  #...

  tags = var.common_tags
}

variable "upgrade_channel" {
  type        = string
  description = "Sets the upgrade channel to patch, rapid, node-image, or stable"
  default     = null # "" is invalid!
}

resource "azurerm_kubernetes_cluster" "main" {
  #...
  automatic_upgrade_channel = var.upgrade_channel
}