$Env:TF_ENCRYPTION = @"
key_provider "aws_kms" "tofu" {
  kms_key_id = "90ea3863-9d9a-4032-a3c0-0539a5b4d105"
  region = "us-west-2"
  key_spec = "AES_256"

}

method "aes_gcm" "tofu" {
  # Method options here
  keys = key_provider.aws_kms.tofu
}

method "unencrypted" "tofu" {
  # Method options here
}

state {
  # Encryption/decryption for state data
  method = method.aes_gcm.tofu

  fallback {
    method = method.unencrypted.tofu
  }
}

plan {
  # Encryption/decryption for plan data
  method = method.aes_gcm.tofu
  fallback {
    method = method.unencrypted.tofu
  }
}
"@