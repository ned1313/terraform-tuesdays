# Return the full service principal object
output "service_principal" {
  value = azuread_service_principal.oidc
  description = "The full service principal object associated with the application."
}