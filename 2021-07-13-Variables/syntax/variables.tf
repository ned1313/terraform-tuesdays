variable "taco" {}

variable "cheese" {
  type = string
  default = "cheddar"
  description = "Type of cheese to put on the taco."
}

variable "tuple" {
  type = tuple([number, list(string), string])
  default = [ 1, ["map"], "yes"]
}

variable "aws_instance_sizes" {
  type = map(string)
  description = "Region to use for AWS resources"
  default = {
    small  = "t2.micro"
    medium = "t2.small"
    large  = "t2.large"
  }
}
