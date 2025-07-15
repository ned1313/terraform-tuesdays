provider "docker" {}

resource "docker_image" "vault" {
  name         = "hashicorp/vault:1.20"
  keep_locally = true
}

resource "docker_container" "vault" {
  name  = "vault"
  image = docker_image.vault.name
  wait  = true

  ports {
    internal = 8200
    external = 8200
  }

  env = [
    "VAULT_DEV_ROOT_TOKEN_ID=root",
    "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200"
  ]

  command = ["server", "-dev"]

  healthcheck {
    test     = ["CMD", "vault", "status", "-address=http://localhost:8200"]
    interval = "10s"
    timeout  = "5s"
    retries  = 3
  }
}