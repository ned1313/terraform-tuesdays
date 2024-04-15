provider "aws" {
  region = "us-west-2"
}


locals {
  layers = flatten([ for l in var.lambdas :
    [ for layer in l.layers : merge({"function_name" = l.function_name},layer) ]
  ])
}
resource "aws_lambda_layer_version" "lambda_layer" {
    for_each = { for layer in local.layers : "${layer.function_name}-${layer.layer_name}" => layer}

    layer_name              = each.value.layer_name
    description             = each.value.description
    compatible_architectures = lookup(each.value, "architectures", null)
    compatible_runtimes     = lookup(each.value, "compatible_runtimes", null)
    #filename                = each.value.filename
    #license_info            = each.value.license_info
    #s3_bucket               = each.value.s3_bucket
    #s3_key                  = each.value.s3_key
    #s3_object_version       = each.value.s3_object_version
    #skip_destroy            = each.value.skip_destroy
    #source_code_hash        = each.value.source_code_hash
  }

resource "aws_lambda_function" "name" {
  for_each = { for lambdas in var.lambdas : lambdas.function_name => lambdas }

  function_name = each.key
  description   = each.value.description
  architectures = each.value.architectures

  ephemeral_storage {
    size  = each.value.ephemeral_storage
  }

  layers = [ for layer in each.value.layers : aws_lambda_layer_version.lambda_layer["${each.key}-${layer.layer_name}"].arn]
  memory_size = each.value.memory_size
  runtime = each.value.runtime
  timeout = each.value.timeout

  role          = var.lambda_role
  filename      = "lambda.zip"
  handler       = "lambda.handler"
  source_code_hash = "0"

}
