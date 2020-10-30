module "azure" {
  source           = "./azure"
  controller_vm_count = 1
  worker_vm_count = 1
}

module "boundary" {
  source              = "./boundary"
  url                 = module.azure.controller_url
  target_ips          = module.azure.target_ips
  tenant_id = module.azure.tenant_id
  vault_name = module.azure.vault_name
}