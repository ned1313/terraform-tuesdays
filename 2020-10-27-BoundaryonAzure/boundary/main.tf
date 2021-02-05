terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "0.1.0"
    }
  }
}

provider "boundary" {
  addr             = var.url
  recovery_kms_hcl = <<EOT
kms "azurekeyvault" {
    purpose = "recovery"
	tenant_id     = "${var.tenant_id}"
    vault_name = "${var.vault_name}"
    key_name = "recovery"
}
EOT
}