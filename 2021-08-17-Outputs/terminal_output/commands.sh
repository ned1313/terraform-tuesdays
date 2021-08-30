# Start by initiliazing
terraform init

# Next up we'll apply
terraform apply -auto-approve

# Now we can play with outputs
terraform output -json

# Cool, we can parse the json with jq
terraform output -json | jq .random_out.value.result