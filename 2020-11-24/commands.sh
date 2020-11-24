# Go into remotestate-setup

terraform init

terraform validate

terraform plan -out state.tfplan

terraform apply state.tfplan

# Copy the outputs into the file east-config/state1.tfvars

# Now we'll create a second set for the other config
terraform workspace new remote2

terraform plan -var-file="state2.tfvars" -out state2.tfplan

terraform apply "state2.tfplan"

# Copy the outputs into the file east-config/state1.tfvars

# Now deploy our two VPCs

# Go to east-config

# Get terraform ready

terraform init -backend-config="backend.tfvars"

terraform validate

terraform plan -out state1.tfplan

terraform apply "state1.tfplan"

# Move your resources to the new config

# Show resources

terraform state list

# Perform a terraform mv

terraform state mv -state-out="../west-config/terraform.tfstate" 'module.vpc2' 'module.vpc2' 

# Go to west-config and initialize the config

terraform init -backend-config="backend.tfvars"

# Now run a plan and it should come back clean

terraform plan
