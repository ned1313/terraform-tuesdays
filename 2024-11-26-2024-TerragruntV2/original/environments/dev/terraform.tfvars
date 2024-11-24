location        = "eastus"
subscription_id = "4d8e572a-3214-40e9-a26f-8f71ecd24e0d"
prefix          = "tgtest"
common_tags = {
  environment = "dev"
}

cidr_block = "10.0.0.0/16"
subnets = {
  "frontend" = "10.0.0.0/24"
  "backend"  = "10.0.1.0/24"
  "db"       = "10.0.2.0/24"
}