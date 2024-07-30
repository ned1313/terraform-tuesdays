terraform {
  encryption {

    key_provider "pbkdf2" "passphrase" {
      passphrase    = "tacos-are-delicious-and-nutritious"
      key_length    = 32
      iterations    = 600000
      salt_length   = 32
      hash_function = "sha512"
    }

    method "aes_gcm" "passphrase_gcm" {
      keys = key_provider.pbkdf2.passphrase
    }

    state {
      method = method.aes_gcm.passphrase_gcm
    }

    plan {
      method = method.aes_gcm.passphrase_gcm
    }
  }
}