# Set the environment specific values
locals {
  subscription_id = "4d8e572a-3214-40e9-a26f-8f71ecd24e0d"
  location        = "eastus"
  common_tags = {
    environment = "dev"
  }
  prefix          = "tgdev"
  azurerm_version = "4.11.0"
}