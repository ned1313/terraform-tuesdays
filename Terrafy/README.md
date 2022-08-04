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
dev
```

Wow, `dev`. That's um, not really all that helpful. But okay, moving on!

## Deploy the target environment

We need a base environment to import using `aztfy`, and why not use Terraform to do that. In the `setup` directory is a basic configuration that deploys a virtual network and a virtual machine. Make sure you have Azure credentials and a subscription selected either through the Azure CLI or environment variables. From the `setup` directory, run the following:

```bash
terraform init
terraform apply -auto-approve
```

## Import the environment

Time for `aztfy` to do it's magic! Move to the `import` directory and run the following:

```bash
aztfy RG-aztfy
```

Azure Terrafy will look for all resources in the resource group `RG-aztfy` and catalog them. Then it will prompt you to review and potentially import them. If you like what you see, press `w` and it will generate your Terraform configuration and state file.

But hold on a second there pardner. Terrafy doesn't always know exactly which mapping to use for a resource. Taking a look at the listing, our Azure VM is being skipped. Why? Well, that's because there are three different resources in the `azurerm` provider you can use to create an Azure VM: `azurerm_virtual_machine`, `azurerm_linux_virtual_machine`, and `azurerm_windows_virtual_machine`. The oldest of these options, and one that is being deprecated is the `azurerm_virtual_machine`. Terrafy should be able to tell which operating system is in play, `osType` is one of the properties of the Virtual Machine resource, but it still doesn't know whether to use the linux specific resource or the more general one. It's up to you to tell it.

There is the option to hit `r` to show recommendations from the list. Unfortunately, the version of `aztfy` I am using has no suggestions:

```bash
     RG-aztfy   No resource type recommendation is avaialble...
```

It's up to me to create the proper 

## Check the import

Azure Terrafy created a very literal Terraform configuration with all hardcoded values. Take a look at the files generated for the resources and provider.

Terrafy also created a state file based on your target environment, and downloaded the provider plugins. You do not need to run `terraform init` and if you run a `terraform plan` it should come back that no infrastructure changes are needed.

The next step in the process would be to start refactoring the code to be more dynamic and reusable, but at least you now have a Terraform config to start with. Cool stuff!