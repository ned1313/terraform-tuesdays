# Lots of providers require some additional information for config
# So you need to explicitly add them in a block. It also gives you 
# the opportunity to add some meta-arguments like giving the provider
# an alias

provider "azurerm" {
    features {}
    alias = "malibu"
}

# Now I can reference my alias in a resource, after all what's 
# better than some malibu fish tacos? Actually I have no idea.
resource "azurerm_resource_group" "tacos" {
    name = "tacotest"
    location = "East US"
    provider = azurerm.malibu
}