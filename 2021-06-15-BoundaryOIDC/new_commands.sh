# Start up a dev instance of boundary
boundary dev -host-address=localhost -api-listen-address="localhost:9200"

# Authenticate to boundary
boundary  authenticate password -auth-method-id=ampw_1234567890 -login-name=admin

# Log into azure with the CLI
az login

az account set -s SUB_NAME

# Create the resources
terraform init

terraform apply -auto-approve

# Run the output command to grant app access

# Open a browser to http://localhost:9200 and try it out!