# You're going to need to set some environment variables for some of the variables

# From the enable_approle deployment
export VAULT_ADDR=VAULT_ADDRESS
export TF_VAR_role_id=ROLE_ID
export TF_VAR_secret_id=SECRET_ID

# For the Azure subscription and tenant you're targeting
export TF_VAR_tenant_id=TENANT_ID
export TF_VAR_subscription_id=SUBSCRIPTION_ID

# The rest of the variables are configured in the terraform.tfvars file
# If you're using a namespace, be sure to set it. HCP Vault uses the admin namespace by default.

terraform init
terraform apply
