resource "terraform_data" "main" {
  input = terraform.workspace
}

output "workspace" {
  value = terraform_data.main.output
}