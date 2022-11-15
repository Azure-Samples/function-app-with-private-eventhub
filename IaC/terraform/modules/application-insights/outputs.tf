output "instrumentation_key" {
  sensitive = true
  value     = azurerm_application_insights.appi.instrumentation_key
}

output "azurerm_application_insights_connection_string" {
  sensitive = true
  value     = azurerm_application_insights.appi.connection_string
}
