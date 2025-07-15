provider "vault" {
  address = "http://localhost:8200"
  token   = "root"
}

resource "vault_mount" "kvv2" {
  path        = var.secret_mount_path
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"

  depends_on = [ docker_container.vault ]
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