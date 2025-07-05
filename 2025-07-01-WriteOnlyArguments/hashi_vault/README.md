# HashiCorp Vault Ephemeral Values and Write-only Arguments

This configuration will set up a KV store and write a new secret using an ephemeral input variable to and a write-only argument.

It will also create a policy for accessing the secret, set up the userpass auth method with a new terraform user, and associate the policy with the terraform user.

There is a second configuration in the hashi_vault_access directory that will leverage this userpass auth method with ephemeral inputs going to a vault provider block, to access the secret value using an ephemeral block and use the contents to populate an Azure Key Vault secret.