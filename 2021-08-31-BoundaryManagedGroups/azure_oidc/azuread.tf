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
  app_name = "boundary-${random_integer.suffix.result}"
  boundary_group_name = "boundary-admins-${random_integer.suffix.result}"
}

# Create application in Azure AD
resource "azuread_application" "boundary_oidc" {
  display_name               = local.app_name

  group_membership_claims = ["All"]
  owners = [data.azuread_client_config.current.object_id]
  
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }

    resource_access {
      id   = "b4e74841-8e56-480b-be8b-910348b18b4c" # User.ReadWrite
      type = "Scope"
    }

    resource_access {
      id = "98830695-27a2-44f7-8c18-0c3ebc9698f6" # GroupMember.Read.All
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
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "boundary_oidc" {
  service_principal_id = azuread_service_principal.boundary_oidc.object_id
}

resource "azuread_group" "boundary_admin" {
  display_name = local.boundary_group_name
  security_enabled = true
  members = [data.azuread_client_config.current.object_id]

}
output "tenant_id" {
  value = azuread_service_principal.boundary_oidc.application_tenant_id
}

output "client_id" {
  value = azuread_service_principal.boundary_oidc.application_id
}

output "client_secret" {
  value = azuread_service_principal_password.boundary_oidc.value
  sensitive = true
}

output "group_id" {
  value = azuread_group.boundary_admin.object_id
}

output "grant_command" {
  value = "az ad app permission grant --id ${azuread_service_principal.boundary_oidc.application_id}  --api ${data.azuread_service_principal.microsoft_graph.id}"
}