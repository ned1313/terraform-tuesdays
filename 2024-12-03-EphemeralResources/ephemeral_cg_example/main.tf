provider "azurerm" {
  features {}

}

ephemeral "azurerm_key_vault_secret" "example" {
  name         = var.key_vault_secret_name
  key_vault_id = var.key_vault_id
}

ephemeral "azurerm_key_vault_certificate" "example" {
  name         = var.key_vault_certificate_name
  key_vault_id = var.key_vault_id
}

resource "azurerm_resource_group" "example" {
  name     = "ephemeral-resources"
  location = "East US"
}

resource "azurerm_container_group" "example" {
  name                = "ephemeral-continst"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  ip_address_type     = "Public"
  dns_name_label      = "aci-label"
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    secure_environment_variables = {
      KEY_VAULT_SECRET = ephemeral.azurerm_key_vault_secret.example.value
    }

    ports {
      port     = 443
      protocol = "TCP"
    }
  }

  #provisioner "local-exec" {
  #  command = "echo ${ephemeral.azurerm_key_vault_secret.example.value}"
  #  
  #}

  tags = {
    environment = "testing"
  }
}