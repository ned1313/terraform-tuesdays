# Based on a public preview and GitHub issue: https://github.com/hashicorp/terraform-provider-azurerm/issues/15846
# This may not work in your region or at all.

resource "azurerm_resource_group" "example" {
    name     = "resource-update"
    location = "eastus"
}


resource "azurerm_storage_account" "example" {
  name = "examplednsendpoint42"
  location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    account_tier = "Standard"
    account_replication_type = "LRS"
}

# Based on the JSON here:https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?tabs=json#property-values
# But the property in the API is actually DnsEndpointType not dnsEndpointType
resource "azapi_update_resource" "example" {
  type = "Microsoft.Storage/storageAccounts@2021-09-01"
  resource_id = azurerm_storage_account.example.id

  body = jsonencode({
    properties = {
      DnsEndpointType = "AzureDnsZone"
    }
  })
}
