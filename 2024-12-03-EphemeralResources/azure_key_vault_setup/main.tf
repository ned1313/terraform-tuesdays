provider "azurerm" {
  features {}
}

resource "random_integer" "example" {
  min = 10000
  max = 99999

}

locals {
  name = "${var.prefix}-ephemeral-${random_integer.example.result}"
}

resource "azurerm_resource_group" "example" {
  name     = local.name
  location = "West Europe"
}

data "azurerm_client_config" "example" {

}

resource "azurerm_key_vault" "example" {
  name                = local.name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.example.tenant_id
  sku_name            = "standard"


}

resource "azurerm_key_vault_secret" "example" {
  name         = "secret-sauce"
  value        = "adobo"
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_key_vault_certificate" "example" {
  name         = "my-generated-cert"
  key_vault_id = azurerm_key_vault.example.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["chicken.tacos.com"]
      }

      subject            = "CN=chicken-tacos"
      validity_in_months = 12
    }
  }
}