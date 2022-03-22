variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region for the specified resources."
}

variable "functions_worker_runtime" {
  type        = string
  description = "The language worker runtime to load in the function app."
}

variable "azurerm_app_service_plan_name" {
  type        = string
  description = "The name of the App Service plan."
}

variable "azurerm_function_app_name" {
  type        = string
  description = "The name of the function app."
}

variable "azurerm_function_app_storage_account_name" {
  type        = string
  description = "The Azure storage account name which will be used by the function app."
}

variable "azurerm_function_app_storage_account_access_key" {
  type        = string
  description = "The access key which will be used to access the Azure storage account for the function app."
  sensitive   = true
}

variable "azurerm_function_app_appinsights_instrumentation_key" {
  type        = string
  description = "The Application Insights instrumentation key used by the function app."
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
