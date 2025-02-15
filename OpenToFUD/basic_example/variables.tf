variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "prefix" {
  description = "Prefix to be used for resource naming"
  type        = string
  default     = "demo"
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    FUD         = "none"
  }
}
