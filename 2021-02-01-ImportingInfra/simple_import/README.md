# Working through a simple deployment

In this simple example, we are going to walk through what happens with the Terraform state file as we create Azure infrastructure using a Terraform configuration. Then we will create the same infrastructure using an ARM template and import it into Terraform using the import command.

# Deploying with Terraform

From the `terraform` subfolder run the following commands to deploy the basic VNet:

```bash
az login
az account set -s SUBSCRIPTION_NAME

terraform init
terraform apply -auto-approve
```

Now that we've got ourselves a basic VNet, let's look at what is in the state file.

```bash
more terraform.tfstate
```

Observe that each resource has an `id` property in the `attributes` that corresponds to the resource ID of the Azure resource. With that in mind, let's destroy our environment.

```bash
terraform destroy -auto-approve
```

# Deploy using an ARM template

Instead of deploying an environment using Terraform, we are going to use an ARM template. Head into the `arm` directory and run the following to get it deployed.

```bash
# Log into Azure and select the correct subscription
az login
az account set -s SUBSCRIPTION_NAME

# Let's set a few variables to use for the deployment
rg_name="tacos"
location="eastus"

# Create a resource group in the current subscription
az group create -n $rg_name -l $location

# Create a deployment in the resource group we just created
az deployment group create \
  --name "terraform-tuesday-import" \
  --resource-group $rg_name \
  --template-file azuredeploy.json
```

To perform the import we are going to need the resource ID of the virtual network and two subnets:

```bash
az deployment group show \
  -n "terraform-tuesday-import" \
  -g $rg_name | jq .properties.outputs[].value
```

# Import that infrastructure!

Head back to the terraform directory and delete the current `terraform.tfstate` file, as well as any state backups and the `.terraform` folder. We are going to reinitialize our terraform configuration and run the necessary import commands.

```bash
terraform init
rg_id=
vnet_id=
subnet1_id=
subnet2_id=

terraform import azurerm_resource_group.vnet $rg_id

# Before you run the rest of the commands, check out our new state file!

# Okay, now run the rest
terraform import azurerm_virtual_network.vnet $vnet_id
terraform import 'azurerm_subnet.subnets[0]' $subnet1_id
terraform import 'azurerm_subnet.subnets[1]' $subnet2_id
```

Now if we run a `terraform plan`, it should some back with no changes necessary. We did it! If you want to have a little fun, make a change and verify it works, like adding a tag to the VNet.

# Challenge time!

I've started an example of a more complex deployment using an ARM template. We've got a VNet, storage account, NSG, VM, and more! Can you get the whole thing deployed using ARM and then successfully import it into Terraform? 

Let me know how you do!