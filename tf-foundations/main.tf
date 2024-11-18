variable "resource_group_count" {
  type = number
  default = 2
}

variable "subscription_id" {
  type = string
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "main" {
  count = var.resource_group_count
  name     = "myResourceGroup-${count.index + 1}"
  location = "East US"
}


resource "azurerm_resource_group" "main2" {
  for_each = toset(["foreach-1", "foreach-2"])
  name     = each.key
  location = "East US"
}

resource "aws_security_group" "hashi-server" {
  vpc_id = aws_vpc.vpc.id
  name   = "hashi-server"

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value["from"]
      to_port     = ingress.value["to"]
      protocol    = "tcp"
      cidr_blocks = [ingress.value["cidr"]]
    }
    
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}