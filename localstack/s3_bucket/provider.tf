provider "aws" {
  region     = "us-east-1"
  access_key = "fake"
  secret_key = "fake"

  s3_use_path_style           = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://s3.localhost.localstack.cloud:4566"
  }

}