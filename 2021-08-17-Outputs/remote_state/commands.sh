# First go into the network directory
# You'll need to update the backend settings for your 
# instance of Terraform Cloud

# You'll also need to create an Azure SP for the remote run.
# Add the following environment variables and values to your config
# ARM_SUBSCRIPTION_ID
# ARM_CLIENT_ID
# ARM_CLIENT_SECRET 
# ARM_TENANT_ID 

# Now we can initiliaze and apply
# Start by initiliazing
terraform init

# Next up we'll apply
terraform apply -auto-approve

# Now move to the web_app folder
# Start by initiliazing
terraform init

# Next up we'll apply
terraform apply -auto-approve