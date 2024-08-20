$env:TF_ENCRYPTION = @"
key_provider "aws_kms" "tofu" {
  kms_key_id = "62b4299c-0e4e-4323-98dc-e185d8dfe7b9"
  region = "us-west-2"
  key_spec = "AES_256"
}

method "aes_gcm" "tofu" {
  keys = key_provider.aws_kms.tofu
}

method "unencrypted" "tofu" {}

state {
  method = method.aes_gcm.tofu

  fallback {
    method = method.unencrypted.tofu
  }
}

plan {
  method = method.aes_gcm.tofu
  
  fallback {
    method = method.unencrypted.tofu
  }
}
"@