terraform {
  required_providers {
      test = {
          source = "terraform.io/builtin/test"
      }

      http = {
          source = "hashicorp/http"
      }
  }
}

module "main" {
    source = "../.."
    
}

locals {
  url = "http://${module.main.url}:8080"
}

data "http" "inventory" {
  url = "${local.url}/api/store/inventory"

  request_headers = {
      accept = "application/json"
  }

}

resource "test_assertions" "content_type" {
  
  component = "headers"

  equal "content_type" {
      description = "Response is a 200 code"
      got = data.http.inventory.response_headers.Content-Type
      want = "application/json"
  }
}

resource "test_assertions" "content_json" {
  
  component = "response_content"

  check "content_json" {
      description = "Content is valid JSON"

      condition = can(jsondecode(data.http.inventory.body))
  }
}