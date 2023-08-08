# Create the vnet with terraform
terraform init
terraform apply -auto-approve

# Create a third subnet using the cli
az network vnet subnet create -g BurritoBarn --vnet-name BurritoBarn --name web3 --address-prefixes "10.0.2.0/24"

# Get the subnet ID
az network vnet subnet show -g BurritoBarn --vnet-name BUrritoBarn --name web3 --query id -o tsv

# Show the current state entries
terraform state list

# Add the import block and update the terraform.tfvars to include the third subnet
# Run a terraform plan and verify results
terraform plan

# Run a terraform apply and then remove the import block
terraform apply