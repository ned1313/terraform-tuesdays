provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url       = local.azp_url
  personal_access_token = var.azp_token
}