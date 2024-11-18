variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
}

variable "ingress_port" {
  description = "The port to allow ingress traffic on"
  type        = number
  default     = 80
}

variable "instance_name" {
  description = "The name of the instance"
  type        = string
  default     = "WebServer"
}

variable "instance_type" {
  description = "The instance type to use for the instance"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "The subnet ID to use for the instance"
  type        = string
}

variable "user_data" {
  description = "The user data to use for the instance"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to use for the security group"
  type        = string

}
