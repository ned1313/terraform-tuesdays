output "fe_fqdn" {
  value = "https://${module.frontend.frontend_public_dns}"

}

output "be_ip_address" {
  value = module.backend.backend_ip_address
}