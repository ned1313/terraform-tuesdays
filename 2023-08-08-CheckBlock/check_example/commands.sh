# Deploy the infrastructure
az login
az account set -S MAS

terraform init
terraform apply -auto-approve

# Run a plan to fire off the checks
terraform plan

# Add a new rule to the NSG
az network nsg rule create -g 'check-block-example' -n allow_ssh --nsg-name 'check-example' --priority 110 --destination-port-ranges '22' --protocol Tcp --description 'Allow SSH'

# Shut down the VM
az vm deallocate -g 'check-block-example' -n 'check-vm'