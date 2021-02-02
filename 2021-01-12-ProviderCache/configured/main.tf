# You used to set the provider version in the provider block
# But that is no longer the case, you now specify it in the 
# terraform.required_providers block

# You can also do silly things, like name the provider whatever you want.
# I'm annoyed it's called AzureRM, so I'm calling it Azure.
terraform {
    required_providers {
        azure = {
            source = "hashicorp/azurerm"
            version = "2.41.0"
        }
    }
}

# Which means I can refer to it as Azure in my provider declaration
provider "azure" {
    features {}
    alias = "malibu"
}

resource "azurerm_resource_group" "tacos" {
    name = "tacotest"
    location = "East US"
    # I also have to use the proper addressing of the provider alias, since
    # I have changed the name
    provider = azure.malibu
}