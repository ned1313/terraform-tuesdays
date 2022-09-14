# Azure Terrafy (I'm so scared)

First things first, you're going to need the `aztfy` tool to run through this demo. The easiest way to do this is to install it via `go`. That presupposes you have Go installed on your system, which if you don't go ahead and do so now. Once Go is installed, run the following command:

```bash
go install github.com/Azure/aztfy@latest
```

You can check the version of aztfy installed by running this command:

```bash
aztfy -v
```

```bash
aztfy version v0.6.0(18b614b)
```

The current version when I wrote this was `0.6.0`, but you can always find the latest version on the [releases page](https://github.com/Azure/aztfy/releases).

## Deploy the target environment - WITH TERRAFORM

We need a base environment to import using `aztfy`, and why not use Terraform to do that? In the `setup` directory is a basic configuration that deploys a virtual network and a virtual machine. Make sure you have Azure credentials and a subscription selected either through the Azure CLI or environment variables. From the `setup` directory, run the following:

```bash
terraform init
terraform apply -auto-approve
```

## Deploy the target environment - WITHOUT TERRAFORM

We need a base environment, but maybe using Terraform to do that is a little to convenient for you? After all, you'd probably use an ARM template or the Azure CLI to deploy things in the first place. So, let's do that. Here's the commands to deploy an Azure VM in a virtual network:

```bash
# Set the resource group name and location
rgname="RG-aztfy"
location="eastus"

# Create the resource group
az group create --name $rgname --location $location

# Create the virtual machine with an implicit virtual network
az vm create --resource-group $rgname --name tacoVM --image UbuntuLTS --admin-username tacoadmin --generate-ssh-keys
```

## Import the environment

Time for `aztfy` to do it's magic! Move to the `import` directory and run the following:

```bash
aztfy resource-group RG-aztfy
```

Azure Terrafy will look for all resources in the resource group `RG-aztfy` and catalog them. Then it will prompt you to review and potentially import them. If you like what you see, press `w` and it will generate your Terraform configuration and state file.

But hold on a second there pardner. Terrafy doesn't always know exactly which mapping to use for a resource. For example, there are three different resources in the `azurerm` provider you can use to create an Azure VM: `azurerm_virtual_machine`, `azurerm_linux_virtual_machine`, and `azurerm_windows_virtual_machine`. The oldest of these options, and one that is being deprecated is the `azurerm_virtual_machine`. Terrafy should be able to tell which operating system is in play, `osType` is one of the properties of the Virtual Machine resource, but it may not be right all the time. When Terrafy doesn't know which resource type to pick, it will not include it in the Terraform configuration, unless you manually specify the resource type.

There is the option to hit `r` to show recommendations from the list. You mileage may vary, but it's worth trying:

```bash
     RG-aztfy   No resource type recommendation is available...
```

If there's no suggestion, then you can specify the resource type and Terrafy will do its best to find the right attribute mappings.

## Check the import

Azure Terrafy created a very literal Terraform configuration with all hardcoded values. Take a look at the files generated for the resources and provider.

Terrafy also created a state file based on your target environment, and downloaded the provider plugins. You do not need to run `terraform init` and if you run a `terraform plan` it should come back that no infrastructure changes are needed.

The next step in the process would be to start refactoring the code to be more dynamic and reusable, but at least you now have a Terraform config to start with. Cool stuff!
