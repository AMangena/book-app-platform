# modules/webapp/outputs.tf — what the module returns to each environment.
output "app_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}
output "app_name" {
  value = azurerm_linux_web_app.app.name
}
output "resource_group" {
  value = azurerm_resource_group.rg.name
}
