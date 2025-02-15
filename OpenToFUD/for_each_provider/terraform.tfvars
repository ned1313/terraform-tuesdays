vpc_config_by_region = {
  "us-west-2" = {
    cidr            = "10.0.0.0/16"
    public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnets = []
  }
  "us-east-1" = {
    cidr            = "10.1.0.0/16"
    public_subnets  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
    private_subnets = []
  }
}