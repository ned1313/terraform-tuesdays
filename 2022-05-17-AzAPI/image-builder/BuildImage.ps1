# First run terraform to set up the infrastructure
terraform init
terraform apply -auto-approve

# Extract outputs for the resource group
$imageResourceGroup = $(terraform output -raw resource_group_name)
$imageTemplateName = $(terraform output -raw template_name)

# Install the ImageBuilder module
Install-Module Az.ImageBuilder

# Build the image once the template has finished deploying, this may take a while (20-30 minutes)
# use the -NoWait switch to run the build in the background
Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName

# When you are finished with the compute gallery, you'll need to delete the 
# image version created by the template before running terraform destroy


