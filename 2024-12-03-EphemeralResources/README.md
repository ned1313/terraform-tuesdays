# Ephemeral Resources in Terraform

Terraform 1.10 has introduced the concept of ephemeral resources, outputs, and variables to Terraform. Before I dig into the details of how they work, first I think it's important to understand the problem ephemerals are trying to solve.

We all know that Terraform state can contain sensitive information. After all, it contains all the attributes of each resource and data source and any output values defined in the configuration. Terraform uses these values to calculate an execution plan when updates are made to the configuration.

An additional concern is sensitive information found in saved Terraform plan files. Plan files not only contain the entirety of the configuration, but also the planned changes and variable values used to create the plan.

How can you remove sensitive information from state data and saved plans? That is what ephemeral resources are meant to do. Unlike data sources or managed resources, an ephemeral resource and its attributes are never written to state or an execution plan. Additionally, ephemeral resources and their properties cannot be used in the context of a non-ephemeral object. If they could, then the values of the ephemeral resource would end up in state or a plan, and would defeat the purpose behind them.

Given that you can't use an ephemeral resource's attributes inside of a managed resource or data source, what good are they? Well, the primary use case seems to be provider authentication. And in fact that's the first time I encountered them.

If you go back and watch my HCP Terraform Stacks video or just look at the code, I declare a stack variable called identity_token:

```hcl
variable "identity_token" { 
  type      = string 
  ephemeral = true
}
```

This token is used to authenticate to Azure through OIDC. It's meant to be used a single time and doesn't need to persist anywhere.

The provider configuration for the stack uses the `identity_token` value for the `oidc_token` argument:

```hcl
provider "azurerm" "this" {
  config {
    features {}

    use_cli = false

    use_oidc = true
    oidc_token = var.identity_token
    client_id = var.client_id
    subscription_id = var.subscription_id
    tenant_id = var.tenant_id
  }
}
```

The value for the identity token comes from a special block type specific to Terraform Stack called `identity_token`:

```hcl
identity_token "azurerm" {
  audience = ["api://AzureADTokenExchange"]
}
```

This block type predates the release of 1.10 of Terraform and I think will probably be replaced with an ephemeral resource, so let's take a look at the syntax of ephemeral resources and some examples to better understand the syntax and restrictions on ephemeral resources.

## Syntax

The syntax for an ephemeral resource is basically the same as a managed resource:

```hcl
ephemeral "<ephemeral_resource_type>" "<name_label>" {
    <identifier> = <expression>
}
```

You can't use a provider's managed resource types as ephemeral resources. Instead, ephemeral resources are a separate category in the provider documentation and require a different implementation in the plugin. Currently, the AzureRM, AWS, and GCP providers have all added support for ephemeral resources, with more coming in the future.

The `azurerm` provider supports two ephemeral resources types in version `4.11.0` of the provider:

- `azurerm_key_vault_secret`
- `azurerm_key_vault_certificate`

If you have a secret stored in Key Vault that you want to use, the syntax for the ephemeral resource would be:

```hcl
ephemeral "azurerm_key_vault_secret" "example" {
  name         = var.key_vault_secret_name
  key_vault_id = var.key_vault_id
}
```

Now what can you do with this secret? Can you use it in a regular resource?:

```hcl
resource "azurerm_container_group" "example" {
  name                = "ephemeral-continst"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  #...

  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    secure_environment_variables = {
      KEY_VAULT_SECRET = ephemeral.azurerm_key_vault_secret.example.value
    }

  }
}
```

Nope! When you run `terraform validate` you'll get the error:

```bash
Error: Invalid use of ephemeral value
│
│   with azurerm_container_group.example,
│   on main.tf line 36, in resource "azurerm_container_group" "example":
│   36:       KEY_VAULT_SECRET = ephemeral.azurerm_key_vault_secret.example.value
│
│ Ephemeral values are not valid in resource arguments, because resource instances must persist between Terraform phases.
```

To generate a proper execution plan, Terraform would have to persist the secret value beyond the planning phase. Since we're trying to avoid that, Terraform throws an error.

So if we can't use ephemeral values with regular resources or data sources, where can we use them? You can use them with the follow object types:

- Local values: The local value will inherit the ephemeral marker.
- Provider blocks: You can use ephemeral values to configure the properties of a provider.
- Ephemeral resources: You can reference the attribute of one ephemeral resource in another since neither persists.
- Ephemeral variables: You can pass an ephemeral value to a child module if the input variable is marked as ephemeral.
- Ephemeral outputs: You can pass an ephemeral value to a parent module if the output is marked as ephemeral.
- Provisioner and connection blocks: You can use an ephemeral value to configure a provisioner.

Note that ephemeral outputs cannot be used in the root module, because then they would be written to state. Also, since ephemeral values are not written to the plan file, they are calculated on each Terraform run. So you might get a different value for plan than you do for apply.

Honestly, the biggest use case at the moment is for provider configuration. Say for instance, you are using the Kubernetes provider to deploy a manifest and you have the Kubernetes credentials stored in Azure Key Vault secret. You could grab the secret with an ephemeral resource and pass it to the Kubernetes provider block:

```hcl
ephemeral "azurerm_key_vault_secret" "k8s" {
  for_each = toset(["client-certificate", "client-key", "cluster-ca-certificate"])

  name         = each.key
  key_vault_id = var.key_vault_id
}

provider "kubernetes" {
  host = "https://${var.aks_cluster_host}"

  client_certificate     = base64decode(ephemeral.azurerm_key_vault_secret.k8s["client-certificate"].value)
  client_key             = base64decode(ephemeral.azurerm_key_vault_secret.k8s["client-key"].value)
  cluster_ca_certificate = base64decode(ephemeral.azurerm_key_vault_secret.k8s["cluster-ca-certificate"].value)
}
```

Because the provider configuration is never stored in state or the plan, this is a valid use of an ephemeral resource. You can also use meta-arguments with an ephemeral resource, as shown above with the `for_each` argument. Ephemeral resources also support:

- `depends_on`
- `count`
- `for_each`
- `provider`
- `lifecycle`

The other big use case is probably for provisioners, but here I would remind you that provisioners are considered an anti-pattern and not recommended. If you must though, you could run a remote-exec every time a member is added to a cluster like this:

```hcl
ephemeral "azurerm_key_vault_secret" "example" {
  name         = var.key_vault_secret_name
  key_vault_id = var.key_vault_id
}

resource "terraform_data" "cluster" {
    triggers_replace = azurerm_linux_virtual_machine.cluster[*].id

    connection {
        type        = "ssh"
        user        = "clusteradmin"
        private_key = ephemeral.azurerm_key_vault_secret.example.value
        host        = azurerm_linux_virtual_machine.cluster[0].private_ip_address

    }
    provisioner "remote-exec" {
        inline = [#...]
    }

```

Provisioners also do not write their connection information to state or plan.

### Terraform Stacks

To bring it back all the way to the initial example where we get an OIDC token from HCP Terraform to do authentication to Azure, the existing `identity_token` block might be replaced with:

```hcl
ephemeral "tfe_identity_token" "azurerm" {
    type     = "azurerm"
    audience = ["api://AzureADTokenExchange"]
}

```

## What About Managed Resources?

Ephemeral resources are meant to keep sensitive information out of state, but only for specific use cases. As we saw, if you try and use an ephemeral marked value in a resource, data source, or root module output, you'll get an error.

So what about all those sensitive attributes that might be in managed resources, how do I use a Key Vault secret in a container group and not have it persist in state? Today? You don't in native Terraform. You could assign the container group an identity, grant that identity access to the Key Vault in question, and mount the secret as a container volume. Then Terraform isn't really involved. But if you wanted to pass it directly, you'd use a data source and deal with the fact it's now stored in state.

That's why encrypting and securing your state is so important.

But longer term, there is work being done to create what are called write-only attributes for resources. The value of these attributes is not stored in state, and the current value can only be overwritten, it cannot be read, thus making it write-only.

Write-only attributes are very much in the experimental stage, and they will require that providers update their resource to support the concept. Much in the same way that providers have to add ephemeral resources separately from managed resources.

I don't know what the final shape of write-only attributes will exactly look like, but you can dig through this pull request if you want to see the suggested code changes so far.

## Final Thoughts

Ephemeral resources are the beginning of an answer for keeping sensitive data out of state in a systematic way. 1.10 introduces ephemeral resources, variables, and outputs. And right now, the big use cases are for provider configuration and provisioners. Further development will hopefully include write-only attributes and maybe more?

I should also mention that ephemeral resources are currently in beta and HashiCorp is actively looking for feedback. Their functionality may change in future versions of Terraform, so I wouldn't start using them in production just yet.

If you want to tinker around with ephemeral resources yourself. I have some code examples in my Terraform Tuesdays repository. Remember, you'll need Terraform 1.10 to run them.

So what do you think? Do ephemeral resources solve a challenge you're dealing with today? Do you have suggestions for improvements? Let me know down in the comments!