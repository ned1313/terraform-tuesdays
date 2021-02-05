# You're going to need to create a service principal for Terraform Cloud to use
az login

az account set -s SUBSCRIPTION_NAME

# Get your sub id
sub_id=$(az account show --query id -o tsv)

# Create an SP with contributor access to your sub
sp_info=$(az ad sp create-for-rbac \
  --name dr-mr-tacos --role contributor \
  --scopes /subscriptions/$sub_id)

# Retrieve the info you'll need
# ARM_CLIENT_ID
echo $sp_info | jq .appId -r

# ARM_CLIENT_SECRET
echo $sp_info | jq .password -r

# ARM_SUBSCRIPTION_ID
echo $sub_id

# ARM_TENANT_ID
echo $sp_info | jq .tenant -r

# Log into Terraform
terraform login

# Finish token generation process
# Add remote workspace settings

# Run through terraform process
terraform init
terraform plan
terraform apply
