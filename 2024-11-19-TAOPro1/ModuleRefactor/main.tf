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

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2_ami.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data                   = file("${path.module}/startup.tpl")
  user_data_replace_on_change = true

  tags = {
    Name = "WebServer"
  }
}

resource "aws_security_group" "allow_http" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_string" "bucket_name" {
  length  = 8
  special = false
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "my-bucket-${lower(random_string.bucket_name.result)}"
  force_destroy = true

}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.bucket]
}

output "public_dns" {
  value = "http://${aws_instance.web.public_dns}"

}

output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket

}