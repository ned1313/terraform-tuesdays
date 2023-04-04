# initialize terraform
terraform init

# run a terraform apply
terraform apply -auto-approve

# run a plan with a new value
terraform plan -var simple_string=beef

# run an apply with a new value
terraform apply -var simple_string=beef
