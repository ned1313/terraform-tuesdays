# Log into Azure
az login
az account set -s SUB_NAME

# Init and apply config
terraform init
terraform apply -auto-approve

# Look at the state
terraform state list

# What if we wanted to change the object name?
# Change enchilada to burrito in the state
terraform state mv azurerm_resource_group.enchilada azurerm_resource_group.burrito

# Now update the resource in the config to be called burrito
# And run a terraform plan

terraform plan

# Sweet, no changes needed
# What if we want to move tacos to their own module?
terraform state mv azurerm_resource_group.tacos module.tacos.azurerm_resource_group.tacos

# Now update the config and run a plan to validate

terraform plan

# What if we wanted to move burritos to a totally different config?

terraform state mv -state-out='./burritos/terraform.tfstate' azurerm_resource_group.burrito azurerm_resource_group.burrito

# Now go to that directory and run a plan

terraform plan

