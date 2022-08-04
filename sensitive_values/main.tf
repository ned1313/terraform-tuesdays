variable "sensitive_var" {
  type      = string
  sensitive = true
  default   = "8675309"
}

variable "service_principal_name" {
  type        = string
  description = "The name of the service principal"
  default     = "sensitive-test-sp"
}

data "azuread_client_config" "current" {}

# Create an application
resource "azuread_application" "sp" {
  display_name = var.service_principal_name
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.sp.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "sp" {
  service_principal_id = azuread_service_principal.sp.id
}


output "sensitive_out" {
  value     = var.sensitive_var
  sensitive = true
}

output "client_secret" {
  value     = azuread_service_principal_password.sp.value
  sensitive = true
}

module "subnet-a" {
  count = var.subneta_true ? 1 : 0
}

module "subnet-b" {
  count = var.subneta_true ? 0 : 1
}

variable "map" {
  type = map(string)
  default = {
    name = "ned"
    age = 42
  }
}

variable "object" {
  type = object(any)
  default = {
    name = "ned"
    age = 42
  }
}