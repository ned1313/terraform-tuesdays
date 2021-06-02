# Set the reply URL
variable "reply_url" {
  type = string
  description = "Reply URL of Boundary authentication"
  default = "http://localhost:9200/v1/auth-methods/oidc:authenticate:callback"
}

# Get the Microsoft Graph API ID
data "azuread_service_principal" "microsoft_graph" {
  display_name = "Microsoft Graph"
}

# Get the tenant ID for output
data "azuread_client_config" "current" {}

# Generate a random number for naming
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

locals {
  oauth2_permissions_scopes = { for scope in data.azuread_service_principal.microsoft_graph.oauth2_permission_scopes : scope.value => scope } 
  read_all_scope = local.oauth2_permissions_scopes["GroupMember.Read.All"] # Refer to the local.read_all_scope.id attribute
  app_name = "boundary-${random_integer.suffix.result}"
}

# Create application in Azure AD
resource "azuread_application" "boundary_oidc" {
  display_name               = local.app_name

  required_resource_access {
    resource_app_id = data.azuread_service_principal.microsoft_graph.id
    resource_access {
      id = local.read_all_scope.id
      type = "Scope"
    }
  }

  web {
    redirect_uris = [var.reply_url]
  }
}

# Create a service principal for the application
resource "azuread_service_principal" "boundary_oidc" {
  application_id               = azuread_application.boundary_oidc.application_id
}

resource "random_password" "boundary_oidc" {
  length = 16
}

resource "azuread_service_principal_password" "boundary_oidc" {
  service_principal_id = azuread_service_principal.boundary_oidc.object_id
  value = random_password.boundary_oidc.result
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "client_id" {
  value = azuread_service_principal.boundary_oidc.application_id
}

output "client_secret" {
  value = random_password.boundary_oidc.result
  sensitive = true
}

output "grant_command" {
  value = "az ad app permission grant --id ${azuread_service_principal.boundary_oidc.application_id}  --api ${data.azuread_service_principal.microsoft_graph.id}"
}