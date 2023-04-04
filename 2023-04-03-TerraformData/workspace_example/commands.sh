# initialize terraform
terraform init

# run a terraform apply
terraform apply -auto-approve

# Try switching to a different workspace called test
terraform workspace select test

# Add the -or-create flag
terraform workspace select -or-create test

# Run a terraform apply
terraform apply -auto-approve

# Create and switch to a new workspace called test2
terraform workspace new test2

# Switch back to test with the -or-create flag and see it ignores the flag
terraform workspace select -or-create test