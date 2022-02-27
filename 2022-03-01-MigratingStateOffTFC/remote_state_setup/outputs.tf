output "azure_info" {
  value = {
    RESOURCE_GROUP      = azurerm_storage_account.sa.resource_group_name
    CONTAINER_NAME      = azurerm_storage_container.ct.name
    ARM_CLIENT_ID       = azuread_service_principal.remote_state.application_id
    ARM_CLIENT_SECRET   = nonsensitive(azuread_service_principal_password.remote_state.value)
    ARM_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
    ARM_TENANT_ID       = data.azuread_client_config.current.tenant_id
  }
}