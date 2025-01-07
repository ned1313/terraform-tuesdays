locals {
  csv_data = csvdecode(file("${path.module}/data.csv"))
}

output "csv_parsed" {
  
}

# Create an output that is a map of the server names to the type

output "server_types" {
  
}

locals {
  firewall_rules = csvdecode(file("${path.module}/firewall_rules.csv"))
}

# Create a basic AWS VPC with a single public subnet
provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Using for_each, create security groups and security group rules using the contents of the firewall_rules.csv file.
locals {
  
}

resource "aws_security_group" "main" {

}

resource "aws_vpc_security_group_ingress_rule" "main" {

}

resource "aws_vpc_security_group_egress_rule" "main" {

}
