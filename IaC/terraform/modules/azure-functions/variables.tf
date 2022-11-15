variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region for the specified resources."
}

variable "azurerm_app_service_plan_name" {
  type        = string
  description = "The name of the App Service plan."
}

variable "azurerm_function_app_name" {
  type        = string
  description = "The name of the function app."
}

variable "azurerm_function_app_storage_key_vault_id" {
  type        = string
  description = "Id for the Key Vault secret containing the Azure Storage connection string to be used by the Azure Function."
}

variable "azurerm_function_app_identity_id" {
  type        = string
  description = "Id for the managed identity used by the Azure Function."
}

variable "azurerm_function_app_application_insights_connection_string" {
  type        = string
  description = "The Application Insights connection string used by the function app."
  sensitive   = true
}

variable "azurerm_function_app_website_content_share" {
  type        = string
  description = "The name of the Azure Storage file share used by the function app."
}

variable "azurerm_app_service_virtual_network_swift_connection_subnet_id" {
  type        = string
  description = "The ID for the virtual network subnet used for virtual network integration."
}

variable "azurerm_function_app_app_settings" {
  type        = map(string)
  description = "Collection of additional application settings used by the function app."
}
