#### S3 buckets
variable "aws_bucket_prefix" {
  type    = strings
  #type = string
  
  default = "globo"
}

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

locals {
  bucket_name         = "${var.aws_bucket_prefix}_${random_integer.rand.result}"
  #bucket_name         = "${var.aws_bucket_prefix}-${random_integer.rand.result}"
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket        = local.bucket_name
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

}

#### Instance profiles

resource "aws_iam_instance_profile" "asg" {

  lifecycle {
    create_before_destroy = false
  }

  name = "${terraform.workspace}_asg_profile_bug"
  role = "aws_iam_role.asg.name"
  #role = aws_iam_role.asg.name
}

#### Instance roles

resource "aws_iam_role" "asg" {
  name = "${terraform.workspace}_asg_role"
  path = "/"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
  EOF
}

#### S3 policies

resource "aws_iam_role_policy" "asg" {
  name = "${terraform.workspace}-globo-primary-rds"
  role = aws_iam_role.asg.ids
  #role = aws_iam_role.asg.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:*"
        ],
        "Effect": "Allow",
        "Resource": [
                "arn:aws:s3:::${local.bucket_name}",
                "arn:aws:s3:::${local.bucket_name}/*"
            ]
      }
    ]
  }
  EOF
}
