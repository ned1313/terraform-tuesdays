variable "location" {
  description = "The Azure region in which to create all resources."
  default     = "eastus"
}

variable "website_name" {
  description = "The website name to use to create related resources in Azure."
  default     = "tacocat"

  validation {
    condition = length(var.website_name) <= 17
    error_message = "The website name must be 17 characters or fewer."
  }
}

variable "html_path" {
  description = "The file path of the static home page HTML in your local file system."
  default     = "index.html"
}