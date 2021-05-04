variable "api_url" {
  description = "A URL that you would like to test"
  default = "https://google.com"
  type = string
}

output "api_url" {
  value = var.api_url
}