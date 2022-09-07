# Trying out the AzAPI provider

When I'm talking to folks about Terraform, there's one question that keeps coming up. "What if the service or feature I want to use isn't in the provider yet." And that's a completely legitimate question! The pace of development in the cloud means that what's available in the provider is almost always going to lag behind what's supported by the API. There's a limited number of people working on the provider and a limited number of hours in the day, so they have to prioritize and triage features and service requests along with bug fixes and performance improvements.

Now since the providers are open-source, I could tell you to go add it yourself. But that assumes you already know enough Go to do it, and that you have the time/interest in updating and maintaining a portion of the provider. Those are some pretty big assumptions! What to do?

Focusing in on Azure for the moment, there were basically three ways to handle the disparity between provider and API:

* Roll your own provider with the features you need
* Use the ARM template resource to access the features
* Use the Azure CLI or PowerShell outside of Terraform

As we've already discussed, the first option is a non-starter for most folks. I've updated a provider or two in my time and it isn't something I would expect a casual user of Terraform to do.

If you don't mind breaking out of the declarative, state driven model of Terraform, you can always use the Azure CLI or Azure PowerShell modules. Of course, they also suffer from feature/service lag as well.

The final answer is to use ARM templates, which are always at feature parity since they interact directly with the ARM APIs. Basically, if it's supported by the API, it's supported by an ARM template. You can manage an ARM deployment with Terraform using the Template resources of the `azurerm` provider. But there are some caveats to be aware of with using an ARM template.

## ARM Template Problems

When you deploy an ARM template using Terraform, what is being tracked by Terraform is the state of the deployment itself not the resources it creates in Azure. Terraform is aware of the arguments used for the template and the outputs of the template, but that's all it knows about. The actual resources are not stored in state or managed by Terraform.

The solution works in a pinch, but it's definitely a kludge, since it breaks the management model of Terraform. It kind of reminds me of using a remote exec provider, but slightly better.

Anyhow, using the Template resources will work, but you don't have to do that anymore! Now you can interact directly with the Azure APIs using a Terraform provider, the `azapi` provider to be accurate.

## The AzAPI Provider

Microsoft developed the `azapi` provider to address the concern of missing features and services in the `azurerm` provider. And it goes beyond simply adding resources that are generally available in Azure but not yet in the provider. It can also manage properties of existing resources that aren't available in the `azurerm` provider, and manage resources for preview services that are not and may never be in the `azurerm` provider. Basically, if it can be supported by the public Azure APIs, then `azapi` can manage it with Terraform.

So what does it look like to use the provider? Let's step through some real examples I encountered to get a feel for it!

## The Basics

The `azapi` provider only has three resources and two data sources:

* **Resources**
  * `azapi_resource` - used to create and manage an Azure resource
  * `azapi_update_resource` - used to manage attributes of an existing Azure resource
  * `azapi_resource_action` - used to execute modify actions on a resource through the Azure resource manager
* **Data Sources**
  * `azapi_resource` - used to poll any existing Azure resource
  * `azapi_resource_action` - used to execute read-only actions on a resource through the Azure resource manager

The beauty is in its simplicity. If you want to create a resource that isn't supported by the `azurerm` provider, you can use the `azapi_resource`. If you have an existing resource you're configuring with the `azurerm` provider, but it's missing an argument you want to set, you can use the `azapi_update_resource`. Some resources have an action associated with them, list `listKeys` from Azure Automation, that may not have a parallel in the `azurerm` provider. The `azapi_resource_action` resource and data source help you with those cases.

Now that we know why we'd use each resource type, let's dig into a couple of actual examples.

## Creating a resource

When the `azapi` was first announced, I thought it was a cool idea in theory, but I didn't have any immediate application for it. Then a week later I ran into a resource I wanted to deploy in Azure that was missing from the `azurerm` provider. See, I'm working on a new set of courses for Pluralsight all about Azure Virtual Desktop. 

In one of the courses, we are going to use Azure Image Builder to automate the creation of images for AVD session hosts. Azure Image Builder uses Image Templates as the instruction set for building a new image. The template tells Image Builder what to use as a source image, how to customize the image, and where to put the completed image when it's done. Unfortunately, the Image Template resource type didn't exist in the `azurerm` provider. What I had was an ARM template for the deployment of an Image Template. And that's where the `azapi` provider came in.

The overall `azapi_resource` syntax follows this flow:

```terraform
resource "azapi_resource" "example" {
    type = "ResourceType@API-Version"
    name = "Name of Resource"
    parent_id = "Resource Group ID"
    location = "Azure Region"

    body = jsonencode({
        properties = {}
    })
}
```

The contents of the `properties` map will line up with the properties you would specify for the resource type based on the API.

Looking at the ARM template I had for the Image Template, it started like this:

```json
    "type": "Microsoft.VirtualMachineImages/imageTemplates",
    "apiVersion": "2020-02-14",
```

Using that information, set the `type` of my `azapi_resource` as follows:

```terraform
  type = "Microsoft.VirtualMachineImages/imageTemplates@2020-02-14"
```

In fact, if I want to get more information about that specific resource type and version, I can check the [ARM Template docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.virtualmachineimages/imagetemplates?tabs=json).

You can find the full template on the [Azure Image Builder GitHub page](https://github.com/Azure/azvmimagebuilder/blob/main/solutions/14_Building_Images_WVD/armTemplateWVD.json).

The rest of the resource arguments are simply a matter of transposing what's in the ARM template to the proper sections of the resource. Here's what it looked like at the end.

```terraform
resource "azapi_resource" "image_templates" {
  type      = "Microsoft.VirtualMachineImages/imageTemplates@2020-02-14"
  name      = "${local.base_name}-template"
  parent_id = azurerm_resource_group.aib.id
  location  = var.location
  depends_on = [
    azurerm_role_assignment.aib
  ]

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.aib.id
    ]
  }

  tags = {
    imagebuilderTemplate = "AzureImageBuilderSIG"
    userIdentity         = "enabled"
  }

  body = jsonencode({
    properties = {
      buildTimeoutInMinutes = 120
      vmProfile = {
        vmSize       = "Standard_D2_v2"
        osDiskSizeGB = 127
      }
      source = {
        type      = "PlatformImage"
        publisher = local.imagePublisher
        offer     = local.imageOffer
        sku       = local.imageSku
        version   = local.imageVersion
      }
      customize = [
        {
          type        = "PowerShell"
          name        = "OptimizeOS"
          runElevated = true
          runAsSystem = true
          scriptUri   = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/14_Building_Images_WVD/1_Optimize_OS_for_WVD.ps1"
        },
        {
          type                = "WindowsRestart"
          restartCheckCommand = "write-host 'restarting post Optimizations'"
          restartTimeout      = "5m"
        },
        {
          type           = "WindowsUpdate"
          searchCriteria = "IsInstalled=0"
          filters        = ["exclude:$_.Title -like '*Preview*'", "include:$true"]
          updateLimit    = 40
        }
      ]
      distribute = [
        {
          type           = "SharedImage"
          galleryImageId = azurerm_shared_image.aib.id
          runOutputName  = local.runOutputName
          artifactTags = {
            source    = "wvd10"
            baseosimg = "windows10"
          }
          replicationRegions = [
            var.location
          ]
        }
      ]
    }
  })
}
```

Since this is Terraform, I can dynamically create the template based on things like the custom role and identity created for the Image Template, and the source image properties I can define as locals or as variables for user input.

The other thing I couldn't do using the `azurerm` provider was kick off an actual image build, which might be nice! Good thing there's the `azapi_resource_action` resource to the rescue.

Looking at the Image Builder documentation, there is an action for the Image Builder called `Run`. At least there appears to be based on the Azure CLI and PowerShell commands. To that end, I added the following block to make the creation of the image optional:

```terraform
resource "azapi_resource_action" "run_build" {
  type                   = "Microsoft.VirtualMachineImages/imageTemplates@2022-02-14"
  resource_id            = azapi_resource.image_templates.id
  action                 = "run"
  response_export_values = ["*"]

  count = var.build_image ? 1 : 0

  timeouts {
    create = "60m"
  }
}
```

I've included the full example in the `image-builder` directory, so you can try it out.

## Updating an existing resource

I haven't actually come across a use case organically for this one just yet, but I can imagine it would apply heavily to preview properties on resources that aren't supported by the stable API. These properties are not going to be available as arguments in the `azurerm` provider until they go GA, but you might want to use them now.

To find a property that is in preview, I hit up the GitHub issues for the `azurerm` provider and filtered on issues labeled *enhancement*. Sure enough, [I found this issue](https://github.com/hashicorp/terraform-provider-azurerm/issues/15846) that talked about a preview feature coming to Azure storage accounts to allow for DNS zone based endpoints.

[Looking through the JSON docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?tabs=json#property-values) for the `Microsoft.Storage/storageAccounts` resource type, I found the property in question is called `dnsEndpointType` and it can be set to either `Standard` or `AzureDnsZone`.

That means I can create a regular storage account with the `azurerm` provider, and then enable this preview feature using the `azapi_update_resource` resource. And that is exactly what you'll find in the `storage_account` directory.

Note that since this is a preview feature, it might not work for you. I got it to work with my Azure subscription and the East US region.
