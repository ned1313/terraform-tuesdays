# You will need a GCP account and the Google Cloud SDK installed locally. 
# You can install the SDK by following the directions here: https://cloud.google.com/sdk/docs/install

# Once you've install the SDK, go ahead and run the following command to log in

gcloud init

# You're going to be prompted to log in. Select Y to login

# You'll be provided with a link and hopefully a new browser window to log in from

# Select the Google account associated with your GCP account

# Grant the Google Cloud SDK the permissions to access your account

# Next you'll be prompted to select a project or create a new one

# Select an existing project, we'll create a new one shortly

# The configuration is saved as [default]. Terraform will use this saved 
# configuration, unless you switch to a different one.

# If you haven't created a billing account, you'll need to do that now from the portal

# Now we'll create our new project
gcloud projects create taconet-07202021 --set-as-default

# Now we need to associate billing info with our new project, FUN

# Go into the cloud console, go into billing, and Account Management

# Select the My Projects tab and click on the Actions button for the new project and Change Billing

# Select the proper billing account and save the change

# BEFORE we use Terraform, we need to enable some APIs Let's do that first
gcloud services enable compute.googleapis.com

# Now we can FINALLY do some Terraform stuff
# Use the application-default for login auth
gcloud auth application-default login

# A browser window will open, select the same account you used before

# Select Allow on the next screen

terraform init

terraform validate

terraform plan -var gcp_project=PROJECT_ID -out ex1.tfplan

terraform apply ex1.tfplan


