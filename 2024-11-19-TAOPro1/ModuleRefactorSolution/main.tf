provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}



data "aws_ssm_parameter" "amazon_linux_2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

module "web_instance" {
  source = "./modules/instance"

  ami_id        = data.aws_ssm_parameter.amazon_linux_2_ami.value
  ingress_port  = 80
  instance_type = "t2.micro"
  instance_name = "WebServer"
  subnet_id     = aws_subnet.main.id
  vpc_id        = aws_vpc.main.id
  user_data     = file("${path.module}/startup.tpl")

}

moved {
  from = aws_instance.web
  to   = module.web_instance.aws_instance.web
}

moved {
  from = aws_security_group.allow_http
  to   = module.web_instance.aws_security_group.allow_http
}

resource "random_string" "bucket_name" {
  length  = 8
  special = false
}

module "web_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.2"

  bucket                   = "my-bucket-${lower(random_string.bucket_name.result)}"
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"
  acl                      = "private"
  force_destroy            = true

}

moved {
  from = aws_s3_bucket.bucket
  to   = module.web_bucket.aws_s3_bucket.this[0]
}

output "public_dns" {
  value = "http://${module.web_instance.public_dns}"

}

output "bucket_name" {
  value = module.web_bucket.s3_bucket_id

}