variable "location" {
  description = "The Azure region in which to create all resources."
  default     = "eastus"
}

variable "website_name" {
  description = "The website name to use to create related resources in Azure."
  default     = "catmandu"

  validation {
    condition = length(var.website_name) <= 16
    error_message = "Website name must be 16 or less characters. Submitted value was ${length(var.website_name)}"
  }
}

variable "html_path" {
  description = "The file path of the static home page HTML in your local file system."
  default     = "index.html"
}