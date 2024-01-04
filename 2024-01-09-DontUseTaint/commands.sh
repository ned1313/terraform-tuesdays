# Initialize and apply the config
terraform init
terraform apply -auto-approve

# Taint the resource group and view the state
terraform taint azurerm_resource_group.main
terraform state list
terraform state show azurerm_resource_group.main

# It is marked as tainted
# Show the actual state data
cat terraform.tfstate

# Note the status is "tainted"
# Now run a plan
terraform plan

# This is a bit of a ticking time bomb

# Note that it will destroy the resource group
# Now untaint the resource group
terraform untaint azurerm_resource_group.main
cat terraform.tfstate

# Note the status field is gone
# Now run a plan
terraform plan

# Note that it will not destroy the resource group
# What's the better way to do this?
# Use the -replace flag
terraform plan -replace="azurerm_resource_group.main"

# The state is unaltered until you apply!