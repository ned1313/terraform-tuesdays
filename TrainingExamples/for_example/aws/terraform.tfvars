lambdas = [
  {
    function_name     = "deepfilternet"
    description       = "deepfilternet"
    architectures     = ["arm64"]
    ephemeral_storage = 513
    layers = [
      {
        layer_name               = "deepfilternet"
        description              = "deepfilternet"
        compatible_architectures = ["arm64"]
        compatible_runtimes      = ["nodejs"]
      },
      {
        layer_name  = "ffmpeg"
        description = "ffmpeg"
      }
    ]
    memory_size = 129
    runtime     = "python3.9"
    timeout     = 4
  },
  {
    function_name     = "deepfilternet2"
    description       = "deepfilternet2"
    architectures     = ["arm64"]
    ephemeral_storage = 513
    layers = [
      {
        layer_name               = "deepfilternet"
        description              = "deepfilternet"
        compatible_architectures = ["arm64"]
        compatible_runtimes      = ["nodejs"]
      },
      {
        layer_name  = "ffmpeg"
        description = "ffmpeg"
      }
    ]
    memory_size = 129
    runtime     = "python3.9"
    timeout     = 4
  }
]

lambda_role = "arn:aws:iam::123456789012:user/johndoe"