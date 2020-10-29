output "vault_name" {
    value = local.vault_name
}

output "tenant_id" {
    value = data.azurerm_client_config.current.tenant_id
}