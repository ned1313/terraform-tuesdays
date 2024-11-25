variable "common_tags" {
  description = "Common tags to be applied to resources"
  type        = map(string)
}

variable "location" {
  description = "The location where resources will be created"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}