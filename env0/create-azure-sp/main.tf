# This configuration will create an Azure service principal
# and assign it Contributor access to the current subscription

provider "azurerm" {
  features {}
}

variable "service_principal_name" {
  type = string
  description = "The name of the service principal"
  default = "env0-sp"
}

data "azurerm_subscription" "current" {}

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

resource "azurerm_role_assignment" "sp" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.sp.object_id
}

output "client_secret" {
  value = nonsensitive(azuread_service_principal_password.sp.value)
}

output "service_principal_application_id" {
  value = azuread_service_principal.sp.application_id
}

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}
