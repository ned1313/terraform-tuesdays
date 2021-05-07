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

variable "api_url" {
  type = string
  default = "http://msn.com"
}

module "main" {
    source = "../.."
    api_url = var.api_url
    
}

locals {
  api_url_parts = regex(
    "^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?",
    module.main.api_url,
  )
}

resource "test_assertions" "api_url" {
  
  component = "api_url"

  equal "scheme" {
    description = "default scheme is https"
    got         = local.api_url_parts.scheme
    want        = "https"
  }

  check "port_number" {
    description = "default port number is 8080"
    condition   = can(regex(":8080$", local.api_url_parts.authority))
  }
}

data "http" "api_response" {
  depends_on = [
    test_assertions.api_url,
  ]

  url = module.main.api_url
}

resource "test_assertions" "api_response" {
  component = "api_response"

  check "valid_json" {
    description = "base URL responds with valid JSON"
    condition   = can(jsondecode(data.http.api_response.body))
  }
}