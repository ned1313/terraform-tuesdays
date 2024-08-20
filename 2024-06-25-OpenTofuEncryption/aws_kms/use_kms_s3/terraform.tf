terraform {
  backend "s3" {
    region  = "us-west-2"
    bucket  = "tofu-test-encrypted70785"
    key     = "terraform.tfstate"
    encrypt = "true"

    dynamodb_table = "tofu-test-encrypted70785-lock"
  }
}