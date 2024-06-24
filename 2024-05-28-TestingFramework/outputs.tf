output "homepage_url" {
  value = azurerm_storage_blob.homepage.url
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "resource_group_name" {
  value = azurerm_storage_account.main.resource_group_name
}