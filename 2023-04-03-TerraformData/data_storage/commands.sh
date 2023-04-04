# initialize terraform
terraform init

# run a terraform apply
terraform apply -auto-approve

# check out the state data
terraform state list
terraform state show terraform_data.store