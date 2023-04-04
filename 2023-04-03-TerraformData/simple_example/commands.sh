# initialize terraform
terraform init

# Check out the .terraform directory
ls .terraform

# Check out the .terraform.lock.hcl file
cat .terraform.lock.hcl

# Run an apply
terraform apply -var changeme=taco

# Check out the state data
terraform state list
terraform state show null_resource.main
terraform state show terraform_data.main

# Run a plan
terraform plan -var changeme=burrito

# Run an apply
terraform apply -var changeme=burrito