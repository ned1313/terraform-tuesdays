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
        inline = [
            "echo 'Hello, World!'"
        ]
    }
}