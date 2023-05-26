# Create an azure resource group in east us and west us
az group create --name sopes-east --location eastus
az group create --name sopes-west --location westus

# Initialize the terraform configuration
terraform init

# Run a terraform plan with the wrong resource group
terraform plan -var="resource_group_name=sopes-west"

# Run a terraform plan with the correct resource group
terraform plan -var="resource_group_name=sopes-east"