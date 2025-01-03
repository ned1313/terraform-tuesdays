terraform {
  required_providers {
    abbey = {
      source  = "abbeylabs/abbey"
      version = ">= 0.2, < 1.0"
    }
  }
}



resource "random_integer" "main" {
  min = 1
  max = 100
}

resource "abbey_demo" "main" {
  email      = "myemail"
  permission = "abbey"
}