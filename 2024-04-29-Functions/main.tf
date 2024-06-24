provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "main" {
  name     = "function-example"
  location = "East US"
}

locals {
  subnets = {
    subnet1 = "10.0.0.0/24"
    subnet2 = "10.0.1.0/24"
  }
  environment = "dev"
}

module "vnet" {
  source = "Azure/vnet/azurerm"
    version = "4.1.0"
    resource_group_name = azurerm_resource_group.main.name
    vnet_location            = azurerm_resource_group.main.location
    vnet_name                = "${local.environment}-vnet"
    address_space = ["10.0.0.0/16"]
    use_for_each = true

    subnet_names = [for key in keys(local.subnets) : "${local.environment}-${key}"]
    subnet_prefixes = values(local.subnets)
}


resource "azurerm_resource_group" "web" {
  name = "web"
  location = "East US"
}

resource "azurerm_virtual_network" "web" {
  name = "web-vnet"
  resource_group_name = azurerm_resource_group.web.name
  location = "East US"
  address_space = ["10.0.0.0/16"]
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias = "us_east_1"
  region = "us-east-1"
}

resource "aws_instance" "example" {
  provider = aws.us_east_1
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

resource "aws_instance" "example2" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}