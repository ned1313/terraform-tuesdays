variable "lambdas" {
  description = "Lambdas"
  type = list(object({
    function_name     = string
    description       = optional(string)
    architectures     = optional(list(string), ["x86_64"]) # Valid values are ["x86_64"] and ["arm64"]. Default is ["x86_64"].
    ephemeral_storage = optional(number, 512)      # The amount of Ephemeral storage(/tmp) to allocate for the Lambda Function in MB. Default is 512 MB.
    layers = optional(list(object({
      layer_name               = string
      description              = optional(string)
      compatible_architectures = optional(list(string))
      compatible_runtimes      = optional(list(string))
      filename                 = optional(string, "lambda.zip")
      license_info             = optional(string)
      s3_bucket                = optional(string)
      s3_key                   = optional(string)
      s3_object_version        = optional(string)
      skip_destroy             = optional(bool, false)
      source_code_hash         = optional(string)
    })))
    memory_size = optional(number, 128)         # The amount of memory, in MB, that is allocated to your Lambda Function. Default is 128 MB.
    runtime     = optional(string, "python3.8") # The runtime environment for the Lambda function you are uploading. Default is "python3.8".
    timeout     = optional(number, 3)           # The amount of time that Lambda allows a function to run before stopping it. The default is 3 seconds. The maximum allowed value is 900 seconds.
  }))
}

variable "lambda_role" {
  
}