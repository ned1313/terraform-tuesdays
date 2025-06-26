module "local1" {
  source = "./modules/local"

  prefix = "hey"
}

output "name" {
  value = module.local1.local_value
}

output "path_module" {
  value = module.local1.path_module
  
}

output "path_root" {
  value = module.local1.path_root
}


resource "aws_instance" "maybe" {
  for_each = var.instance != {} ? var.instance : {}
}
