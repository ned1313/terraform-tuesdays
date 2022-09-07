output "resource_group_name" {
  value = azurerm_resource_group.aib.name
}

output "template_name" {
  value = azapi_resource.image_templates.name
}

output "build_run" {
  value = azapi_resource_action.run_build
}