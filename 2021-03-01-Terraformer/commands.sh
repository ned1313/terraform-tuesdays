# Install terraformer
export PROVIDER=all
curl -LO https://github.com/GoogleCloudPlatform/terraformer/releases/download/$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | grep tag_name | cut -d '"' -f 4)/terraformer-${PROVIDER}-linux-amd64
chmod +x terraformer-${PROVIDER}-linux-amd64
sudo mv terraformer-${PROVIDER}-linux-amd64 /usr/local/bin/terraformer

# Deploy the basic Vnet
# Change these as desired
location=eastus
rg_name=taconet

az login

az account set -s SUBSCRIPTION_NAME

az group create --location $location --name $rg_name

az deployment group create --name $rg_name \
  --resource-group $rg_name \
  --template-uri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/3a2d11c613643b653e338adb085f11bd4097af36/101-vnet-two-subnets/azuredeploy.json" \
  --parameters vnetName=$rg_name

# Query subscription id from current account in plaintext and set environment variable
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

cd created_environments/azure_vnet

# Check out terraformer flags
terraformer plan azure -h

# Try and run the plan
terraformer plan azure --output hcl --resource-group taconet --resources="*" --verbose

# Whoops
cat <<EOF > versions.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}
EOF

terraform init

# Try and run the plan again
terraformer plan azure --output hcl --resource-group taconet --resources="*" --verbose

terraformer import plan generated/azurerm/terraformer/plan.json

# Check out the files

# Whoof no thanks
rm -rf generated

terraformer plan azure --output hcl --resource-group taconet --resources="*" --compact --path-pattern "{output}/{provider}/"
terraformer import plan generated/azurerm/plan.json

# Better, but can I use it?
cd generated/azurerm

terraform init

# Whelp that was