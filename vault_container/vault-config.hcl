listener "tcp" {
    address          = "0.0.0.0:8200"
    cluster_address  = "0.0.0.0:8201"
    tls_cert_file = "/vault/certs/vault-cert.crt"
    tls_key_file = "/vault/certs/vault-cert.key"
}

storage "file" {
    path = "/vault/data"
}

seal "azurekeyvault" {}

ui = true

disable_mlock = true