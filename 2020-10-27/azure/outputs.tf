output "vault_name" {
    value = local.vault_name
}

output "tenant_id" {
    value = data.azurerm_client_config.current.tenant_id
}

output "controller_url" {
    value = "https://${azurerm_public_ip.boundary.fqdn}:9200"
}

output "target_ips" {
    value = ""
}