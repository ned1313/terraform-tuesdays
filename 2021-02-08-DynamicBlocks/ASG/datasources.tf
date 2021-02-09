##################################################################################
# DATA SOURCES
##################################################################################

data "consul_keys" "applications" {
  key {
      name = "applications"
      path = terraform.workspace == "default" ? "applications/configuration/globo-primary/app_info" : "applications/configuration/globo-primary/${terraform.workspace}/app_info"
  }
  
  key {
    name = "common_tags"
    path = "applications/configuration/globo-primary/common_tags"
  }
}

data "terraform_remote_state" "networking" {
  backend = "consul"

  config = {
    address = "127.0.0.1:8500"
    scheme = "http"
    path     = terraform.workspace == "default" ? "networking/state/globo-primary" : "networking/state/globo-primary-env:${terraform.workspace}"
  }
}

data "aws_ami" "aws_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-20*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
