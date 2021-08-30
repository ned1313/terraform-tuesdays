# Start by initiliazing
terraform init

# Next up we'll apply
terraform apply -auto-approve

# Try it with a different meat
terraform apply -var meat=beef -auto-approve