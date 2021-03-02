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

Indeed. Let us **go**.

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
terraformer plan azure --output hcl --resource-group taconet --resources="*" --verbose
```

```bash
2021/03/01 18:53:43 open /home/ned/.terraform.d/plugins/linux_amd64: no such file or directory
```

Ouch, fail. Seems like I missed something there. Was there an init command I had to run? Ah yes, I missed step 4 of installation. See here's where documentation order matters. They included the step to get Terraform plugins under the *install from source* option, but not for the *package managers* or *release download* option. Since I am not installing from source, I skipped all the steps in that section.

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

Yup. Every single resource type got it's own subdirectory, including a separate state file. Um, ok? I'd rather have one state file for the whole thing. First, why don't we see what's in that `virtual_network` directory.

We've got five files. The `variables.tf` file helps to define the linkage between the Vnet and the resource group. There is a single line data source defined using Terraform state located in the resource_group directory.

```terraform
data "terraform_remote_state" "resource_group" {
  backend = "local"

  config = {
    path = "../../../generated/azurerm/resource_group/terraform.tfstate"
  }
}
```

I have to assume any other related resources would also have a reference data source in the `variables.tf` file. The `provider.tf` file has a weird format. It defines the provider version in both a `provider` block and in a `required_providers` block. That's not really going to fly in newer versions of Terraform, but I guess it's fine for now.

```terraform
provider "azurerm" {
  version = "~> 2.49.0"
}

terraform {
  required_providers {
    azurerm = {
      version = "~> 2.49.0"
    }
  }
}
```

The `virtual_network.tf` file has the single virtual network resource. The `resource_group_name` references the data source defined in the `variables.tf`. What's weird is the `id` property in the subnet block. I don't see that as an official argument. Maybe it will work. I'd also like the subnets to be broken out into their own resources using `azurerm_subnet`. 

```terraform
resource "azurerm_virtual_network" "tfer--taconet" {
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  name                = "taconet"
  resource_group_name = "${data.terraform_remote_state.resource_group.outputs.azurerm_resource_group_tfer--taconet_name}"

  subnet {
    address_prefix = "10.0.1.0/24"
    id             = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/taconet/providers/Microsoft.Network/virtualNetworks/taconet/subnets/Subnet2"
    name           = "Subnet2"
  }

  subnet {
    address_prefix = "10.0.0.0/24"
    id             = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/taconet/providers/Microsoft.Network/virtualNetworks/taconet/subnets/Subnet1"
    name           = "Subnet1"
  }

  vm_protection_enabled = "false"
}
```

The `outputs.tf` file includes only the `id` of the Vnet. That's probably going to be useful if we've got other resources that need to reference it.

```terraform
output "azurerm_virtual_network_tfer--taconet_id" {
  value = "azurerm_virtual_network.tfer--taconet.id"
}
```

Like I said, this is a bit much in terms of folders and files. Let's see if we can shrink things down a bit.

There's a `--compact` option in the list for `plan` and `import`. I'm going to delete the contents of the `generated` folder and try this again.

```bash
rm -rf generated

terraformer plan azure --output hcl --resource-group taconet --resources="*" --compact
terraformer import plan generated/azurerm/terraformer/plan.json
```

Nope, it's exactly the same. What was that `--compact` switch for then? Turns out that switch will group all of the same resource type into the same `resources.tf` file. Since we only have a single instance of the Vnet, `--compact` doesn't do anything. Turns out what I am actually looking for is the `--path-pattern` argument, and I can set it to "{output}/{provider}/" to group all the resources together. Let's try that:

```bash
rm -rf generated

terraformer plan azure --output hcl --resource-group taconet --resources="*" --compact --path-pattern "{output}/{provider}/"
terraformer import plan generated/azurerm/plan.json
```

Note that the path to the plan file has changed a bit.

```bash
.
├── generated
│   └── azurerm
│       ├── outputs.tf
│       ├── plan.json
│       ├── provider.tf
│       ├── resources.tf
│       ├── terraform.tfstate
│       └── variables.tf
└── versions.tf
```

Wow, that's a lot simpler to take in. We've got a single directory and a single state file. Now let's try going into the `generated/azurerm` folder and try initializing Terraform and running a plan.

```bash
cd generated/azurerm

terraform init
```


```bash
Initializing the backend...

Warning: Version constraints inside provider configuration blocks are deprecated

  on provider.tf line 2, in provider "azurerm":
   2:   version = "~> 2.49.0"

Terraform 0.13 and earlier allowed provider version constraints inside the
provider configuration block, but that is now deprecated and will be removed
in a future version of Terraform. To silence this warning, move the provider
version constraint into the required_providers block.


Warning: Interpolation-only expressions are deprecated

  on resources.tf line 10, in resource "azurerm_virtual_network" "tfer--taconet":
  10:   resource_group_name = "${data.terraform_remote_state.local.outputs.azurerm_resource_group_tfer--taconet_name}"

Terraform 0.11 and earlier required all non-constant expressions to be
provided via interpolation syntax, but this pattern is now deprecated. To
silence this warning, remove the "${ sequence from the start and the }"
sequence from the end of this expression, leaving just the inner expression.

Template interpolation syntax is still used to construct strings from
expressions when the template includes multiple interpolation sequences or a
mixture of literal strings and interpolations. This deprecation applies only
to templates that consist entirely of a single interpolation sequence.


Error: Invalid legacy provider address

This configuration or its associated state refers to the unqualified provider
"azurerm".

You must complete the Terraform 0.13 upgrade process before upgrading to later
versions.
```

**Ooof!**, immediate fail on that one. Turns out it doesn't like the version in a provider block, or the old-school style interpolation. Can we tell Terraformer to knock it off? But what about that second error? That's a weird one too.

Looks like the state file is set to version `0.12.29`:

```json
{
    "version": 3,
    "terraform_version": "0.12.29",
    "serial": 1,
    "lineage": "25ad3ca6-b3d5-0bfb-e22f-00c535ce065b",
    "modules": [
```

I'm using Terraform `0.14.4` from the command line, so I need to get Terraformer to respect that in the state file too. How do I go about that? Not sure. Why don't I just fix the provider problem and the interpolation thing while I'm at it.

And nope, that doesn't work at all.

```bash
Initializing the backend...

Error: Invalid legacy provider address

This configuration or its associated state refers to the unqualified provider
"azurerm".

You must complete the Terraform 0.13 upgrade process before upgrading to later
versions.
```

Well, it turns out there is a version 0.8.11 of Terraformer that hasn't hit the release pipeline. I guess I'll build it from source... (2 hours later)... and now I have the latest version based off commits to main. Let's go ahead and try this whole process again...

NOPE. Same weird issue with Terraformer setting the state file Terraform version to `0.12.29`.

What if I delete the state file and just try and validate the config?

```bash
Warning: Interpolation-only expressions are deprecated

  on resources.tf line 10, in resource "azurerm_virtual_network" "tfer--taconet":
  10:   resource_group_name = "${data.terraform_remote_state.local.outputs.azurerm_resource_group_tfer--taconet_name}"

Terraform 0.11 and earlier required all non-constant expressions to be
provided via interpolation syntax, but this pattern is now deprecated. To
silence this warning, remove the "${ sequence from the start and the }"
sequence from the end of this expression, leaving just the inner expression.

Template interpolation syntax is still used to construct strings from
expressions when the template includes multiple interpolation sequences or a
mixture of literal strings and interpolations. This deprecation applies only
to templates that consist entirely of a single interpolation sequence.


Error: "subnet.0.id": this field cannot be set

  on resources.tf line 6, in resource "azurerm_virtual_network" "tfer--taconet":
   6: resource "azurerm_virtual_network" "tfer--taconet" {



Error: "subnet.1.id": this field cannot be set

  on resources.tf line 6, in resource "azurerm_virtual_network" "tfer--taconet":
   6: resource "azurerm_virtual_network" "tfer--taconet" {
```

NOPE. That subnet `id` argument isn't valid, which I was pretty certain of anyway.

At this point, I have to give Terraformer a fail when it comes to working on Azure. It didn't create a valid configuration or a valid state file from a very simple deployment. If that doesn't work right out of the box, then I can't really recommend it.

Now I know some people are going to come at me and say, "it works if you tweak X, Y, and Z". OK, great. But it's not in the docs, and the software doesn't work as advertised. I'm sure part of the problem is all the changes in Terraform since version 11. And I get that it's hard to maintain an open source project. Maybe this works better on AWS or GCP. However, if you list Azure as supported and it doesn't work out of the box, then it isn't really supported.

I hate to say it, but this is where my adventure ends for the moment.
