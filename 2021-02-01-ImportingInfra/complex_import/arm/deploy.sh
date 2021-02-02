# Log into Azure and select the correct subscription
az login
az account set -s SUBSCRIPTION_NAME

# Let's set a few variables to use for the deployment
id=$(((RANDOM%9999+1)))
prefix="tacos"
location="eastus"
resource_group="$prefix-$id"

# Create a resource group in the current subscription
rg=$(az group create -n $resource_group -l $location)

# Create a deployment in the resource group we just created
az deployment group create \
  --name "terraform-tuesday-import" \
  --resource-group $resource_group \
  --template-file azuredeploy.json \
  --parameters @azureparams.json