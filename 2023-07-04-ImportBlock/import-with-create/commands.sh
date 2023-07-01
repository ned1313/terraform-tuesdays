# Initialize terraform as usual
terraform init

# Run a terraform plan with the generate-config-out flag
terraform plan -generate-config-out="generated.tf"

# Run a terraform plan without the flag
terraform plan

# Run a terraform apply
terraform apply