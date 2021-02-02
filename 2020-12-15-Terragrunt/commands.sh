# First go into remotestate and deploy the Azure infra

# Copy the contents of the backend-config.txt file to the stage/terragrunt.hcl file
# where it says to paste the content

# Make sure to install Terragrunt
# From the stage folder
terragrunt validate-all
terragrunt plan-all

# Check out all the files created in the subdirectories