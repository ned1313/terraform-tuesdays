# Run terraform init as usual
terraform init

# Set the Vault token as an environment variable
$VAULT_TOKEN=VAULT_TOKEN

# Set the Vault address as an environment variable
$VAULT_ADDR=VAULT_ADDR

# Run terraform apply as usual
terraform apply

# Record the role id, role path, and secret id