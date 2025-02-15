variable "aws_regions" {
  description = "AWS region to deploy resources"
  type        = list(string)
  default     = ["us-west-2", "us-east-1"]
}

variable "prefix" {
  description = "Prefix to be used for resource naming"
  type        = string
  default     = "demo"
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    FUD         = "none"
  }
}

variable "vpc_config_by_region" {
  description = "VPC configuration by region"
  type = map(object({
    cidr            = string
    public_subnets  = list(string)
    private_subnets = list(string)
  }))

}
