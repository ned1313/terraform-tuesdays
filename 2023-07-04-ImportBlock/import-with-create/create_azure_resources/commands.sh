# Log into Azure with the CLI
az login

# Select the correct subscription
az account set -s SUBSCRIPTION_NAME

# Create a resource group
az group create -n tacoTruck -l eastus

# Deploy the ARM template
az deployment group create -g tacoTruck -n tacoTruck --template-file virtualMachine.json 

# Enter value for password

# Get the resource IDs and save them in a file
az deployment group show -g tacoTruck -n tacoTruck -o table --query properties.outputResources[].id -o table > table.txt