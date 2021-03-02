# TERRAFORMER

I gotta admit, it's a cool name. There's also a really good Thank You Scientist album by the same name, so I might be a little biased. But still, Terraformer is a properly good name, and since I know how hard naming is (looking at you AWS), I want to acknowledge a good name when I see it.

## Setup

We're going to put Terraformer through its paces on Azure. What does that mean? We are going to use existing reference architectures from Microsoft Azure to deploy infrastructure. To avoid the ouroboros-like quality of using Terraform to deploy infrastructure and then using Terraformer to create a Terraform configuration for the infrastructure we already deployed using Terraform (boy am I dizzy), instead we are going to use ARM templates and the Azure CLI to deploy the environments. Could you also create them through the portal? Sure. But like, I don't want to do that and it makes it really hard for you to follow along. Do you really want an hour long video of me clicking through the portal for the setup? Didn't think so.

The templates in question are available on Microsoft's Github. I'll be referencing them directly instead of including them in this repo. Hopefully, Microsoft doesn't break said templates in the future! But I'll try and reference a specific commit to prevent that.

If you are planning to follow along - and I hope you do! - then you are going to need an Azure account. Standard warnings apply that creating resources in an Azure subscription may cost you some amount of money. Be cautious and don't leave things running when you're done. You'll also need the Azure CLI installed, or you could simply use the Cloud Shell. And finally you're going to need Terraformer itself. 

### Installing Terraformer

Terraformer is a CLI based tool created by Waze SRE and it is not officially supported. The version I am testing is v0.8.10. They have installation instructions on the GitHub repo, and I am not going to reproduce them here. My system is running Windows with WSL v2, and I will be running the tests from Ubuntu 18.04 on WSL. Here's what I ran to get Terraformer installed:

```bash
export PROVIDER=all
curl -LO https://github.com/GoogleCloudPlatform/terraformer/releases/download/$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | grep tag_name | cut -d '"' -f 4)/terraformer-${PROVIDER}-linux-amd64
chmod +x terraformer-${PROVIDER}-linux-amd64
sudo mv terraformer-${PROVIDER}-linux-amd64 /usr/local/bin/terraformer
```

Apparently you can install provider specific versions of Terraformer, but I figured why not get the whole kit and caboodle. The file size is 331MB, hefty but not untenable. 

Now what are these environments I speak of? Glad you asked.

### The Environments

We're going to deploy three environments on Azure. Each will be progressively more complicated than the previous. I want to see where Terraformer breaks or needs some help. The environments are as follows:

1. Azure Vnet with two subnets - super simple
1. N-tier application with Cassandra - super complex, but all IaaS
1. Basic Web application - fairly comples, all PaaS

The first deployment is very simple. I really hope Terraformer can handle it, otherwise there's really no point in moving further. The next example is pretty complex with a ton of different resources. But it is still mostly IaaS in nature, including VMs and VNets. I think this is where a lot of organizations might be today, and they might want Terraformer to help them import such a beast into Terraform configs. The last deployment is a PaaS resources, which is more of a future looking proposition. Many orgs probably already deploy something like this using IaC, but they might have used ARM templates or az-cli scripts. Let's see if Terraformer knows how to deal with these resource types.

I should also point out that each environment exists in a single resource group. I am not going to ask Terraformer to deal with a multi-resource group deployment or a multi-region deployment. That's a test for another day. 

### The Test

The test is simple. I am going deploy each of the environments using the Azure CLI. Then I am going to use Terraformer to generate a Terraform config based on the deployment. 

Here's what I would expect:

1. All resources in the resource group are accounted for
1. All resources have the API driven settings accounted for
1. All resources are supported by Terraformer
1. I should be able to import all existing resources into a Terraform state file
1. Running `terraform plan` against the resulting config and state file produces a "no changes are necessary" message

Here's what I don't expect:

1. Terraformer produces elegant configuration files
1. Terraformer offers to break things into modules 
1. Terraformer sets up the state file or backend for me
1. Terraformer knows about the internal configuration outside of the API
1. The environment will be altered in any way after running Terraformer

I want to drive home the point about the internal configuration with regards to the VMs. I do not expect Terraformer to know or care about configuration management inside the Azure VMs. Terraform is not particularly good with config management, and I don't expect Terraformer to help with that. If it's not a setting controlled by the Azure API, then Terraformer is not on the hook for supporting it.

I also don't expect that Terraformer will be able to support every single resource type in Azure. At this point I haven't actually read through the Terraformer docs. This is going to be a journey of exploration and I am documenting this as I go. It's exciting! You should be excited.

ARE YOU ENTERTAINED? (insert plea for Patreon support here)

## Let's GO!

Indeed. Let us go.

### Deployment #1

Like I said there are three environments. The first is based on the basic [Azure Vnet template on GitHub](https://github.com/Azure/azure-quickstart-templates/tree/3a2d11c613643b653e338adb085f11bd4097af36/101-vnet-two-subnets).

Follow along with these fun Azure CLI commands in bash/zsh or WSL:

```bash
# Change these as desired
location=eastus
rg_name=taconet

az login

az account set -s SUBSCRIPTION_NAME

az group create --location $location --name $rg_name

az deployment group create --name $rg_name \
  --resource-group $rg_name \
  --template-uri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/3a2d11c613643b653e338adb085f11bd4097af36/101-vnet-two-subnets/azuredeploy.json" \
  --parameters vnetName=$rg_name
```

Now we've got our first environment deployed. Before we move any further, perhaps we should try Terraformer against this bad boy? No doubt.

### Terraformer

The good news is that we're already using the Azure CLI and Terraformer can use the credentials from the CLI for authentication. The only thing you'll need is the ID of your Azure Subscription set to an environment variable. You can set that with the following command.

```bash
# Query subscription id from current account in plaintext and set environment variable
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

Reading through the docs for Terraformer, they give an excellent list of [what resources are supported](https://github.com/GoogleCloudPlatform/terraformer#use-with-azure). Scrolling through, I do see `azurerm_virtual_network` and that gives me hope that this will work.

Now let's go into the folder that will hold our generated config:

```bash
cd created_environments/azure_vnet
```

And we'll fire up Terraformer. I assume we need to give it some info about what resources to import.

```bash
terraformer plan azure -h
```

We've got the following flags to choose from:

```bash
Flags:
  -b, --bucket string           gs://terraform-state
  -C, --compact
  -c, --connect                  (default true)
  -x, --excludes strings        resource_group
  -f, --filter strings          resource_group=name1:name2:name3
  -h, --help                    help for azure
  -O, --output string           output format hcl or json (default "hcl")
  -o, --path-output string       (default "generated")
  -p, --path-pattern string     {output}/{provider}/ (default "{output}/{provider}/{service}/")
  -R, --resource-group string
  -r, --resources strings       resource_group
  -n, --retry-number int        number of retries to perform when refresh fails (default 5)
  -m, --retry-sleep-ms int      time in ms to sleep between retries (default 300)
  -s, --state string            local or bucket (default "local")
  -v, --verbose
```

My guess is that I would use `--output hcl` to get a `.tf` file, `--resource-group taconet` to select the proper resource group with my resources, `--resources="*"` to select the resources to import, and I'll add in `--verbose` to get a better idea of what's happening.

```bash
terraformer plan azure --output hcl --resource-group taconet --verbose
```

```bash
2021/03/01 18:53:43 open /home/ned/.terraform.d/plugins/linux_amd64: no such file or directory
```

Ouch, fail. Seems like I missed something there. Was there an init command I had to run? Ah yes, I missed step 4 of installation. See here's where documentation order matters. They included the step to get Terraform plugins under the install from source option, but not for the package managers or release download. Since I am not installing from source, I skipped all the steps in that section.

So what to do? Create a `versions.tf` in the destination directory and add a stanza to get the Azure provider plugin.

```bash
cat <<EOF > versions.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}
EOF

terraform init
```

Cool, let's try that again shall we?

```bash
terraformer plan azure --output hcl --resource-group taconet --resources="*" --verbose
```

I won't include the output here, because it was **verbose** indeed. But let's do a tree of what's in my directory now:

```
.
├── generated
│   └── azurerm
│       └── terraformer
│           └── plan.json
└── versions.tf
```

That `plan.json` file has a list of all the discovered resources and the according to the docs, I can make alternations to the plan file and change naming. For instance, the resource will be named `tfer--taconet` according to the file. I don't really care about the names, so let's move forward with an `import` command.

```
terraformer import plan generated/azurerm/terraformer/plan.json
```

Now my updated tree looks like this:

```
.
├── generated
│   └── azurerm
│       ├── analysis
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── app_service
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── container
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── cosmosdb
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── database
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── disk
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── dns
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── keyvault
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── load_balancer
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── network_interface
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── network_security_group
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── private_dns
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── public_ip
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── resource_group
│       │   ├── outputs.tf
│       │   ├── provider.tf
│       │   ├── resource_group.tf
│       │   └── terraform.tfstate
│       ├── scaleset
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── security_center_contact
│       │   ├── provider.tf
│       │   └── terraform.tfstate
│       ├── security_center_subscription_pricing
│       │   ├── provider.tf
│       │   └── terraform.tfstate
│       ├── storage_account
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── storage_blob
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── storage_container
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       ├── terraformer
│       │   └── plan.json
│       ├── virtual_machine
│       │   ├── provider.tf
│       │   ├── terraform.tfstate
│       │   └── variables.tf
│       └── virtual_network
│           ├── outputs.tf
│           ├── provider.tf
│           ├── terraform.tfstate
│           ├── variables.tf
│           └── virtual_network.tf
└── versions.tf
```

Yup. Every single resource type got it's own subdirectory, including a separate state file. Um, ok? I'd rather have one state file for the whole thing. Let's see if that's an option.