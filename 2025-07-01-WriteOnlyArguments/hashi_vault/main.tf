provider "vault" {
  # Use environment variables for Vault address and token
}

resource "vault_mount" "kvv2" {
  path        = var.secret_mount_path
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

# Create a KV v2 secret backend
resource "vault_kv_secret_backend_v2" "main" {
  mount        = vault_mount.kvv2.path
  cas_required = false
  max_versions = 10
}

# Create a secret with burrito recipe
resource "vault_kv_secret_v2" "burrito_recipe" {
  mount                = vault_kv_secret_backend_v2.main.mount
  name                 = "burrito-recipe"
  data_json_wo         = jsonencode(var.burrito_recipe)
  data_json_wo_version = var.burrito_recipe_version
}

# Create policy for accessing the burrito recipe
resource "vault_policy" "burrito_recipe_policy" {
  name = "burrito-recipe-policy"

  policy = <<EOT
# Allow listing secrets in the path
path "${var.secret_mount_path}/metadata/burrito-recipe" {
  capabilities = ["read", "list"]
}

# Allow reading the actual secret content
path "${var.secret_mount_path}/data/burrito-recipe" {
  capabilities = ["read", "list"]
}
EOT
}

# Enable the userpass auth method
resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

# Create a user named Terraform with the burrito recipe policy
resource "vault_generic_endpoint" "terraform_user" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/terraform"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["${vault_policy.burrito_recipe_policy.name}"],
  "password": "tacosarebetter"
}
EOT
}