# You can add a provider by implictly calling one from a data source
# or from a resource. At it's most basic, we could use the Azure
# provider by having a single resource group resource.

resource "azurerm_resource_group" "tacos" {
    name = "tacotest"
    location = "East US"
}

# By running `terraform init`, you will get the Azure provider
# to download into your .terraform/providers directory
# BTW, the full path is .terraform/providers/provider_registry_location/company_name/provider_name/version/platform/*.exe
# That is.. a long path. 
