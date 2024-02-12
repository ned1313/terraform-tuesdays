variable "website_url" {
  type = string
}

data "http" "main" {
  url = var.website_url
}