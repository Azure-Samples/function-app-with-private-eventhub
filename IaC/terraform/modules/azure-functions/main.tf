resource "azurerm_service_plan" "plan" {
  name                = var.azurerm_app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "EP1"
  os_type             = "Windows"
}

resource "azurerm_windows_function_app" "func" {
  name                = var.azurerm_function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id                 = azurerm_service_plan.plan.id
  storage_key_vault_secret_id     = var.azurerm_function_app_storage_key_vault_id
  key_vault_reference_identity_id = var.azurerm_function_app_identity_id
  functions_extension_version     = "~3"
  builtin_logging_enabled         = false

  identity {
    type         = "UserAssigned"
    identity_ids = [var.azurerm_function_app_identity_id]
  }

  site_config {
    runtime_scale_monitoring_enabled = true
    vnet_route_all_enabled           = true
    ftps_state                       = "Disabled"

    application_insights_connection_string = var.azurerm_function_app_application_insights_connection_string

    application_stack {
      dotnet_version = "3.1"
    }
  }

  app_settings = merge(var.azurerm_function_app_app_settings, {
    WEBSITE_CONTENTOVERVNET              = 1
    WEBSITE_CONTENTSHARE                 = var.azurerm_function_app_website_content_share
    WEBSITE_SKIP_CONTENTSHARE_VALIDATION = 1
  })
}

resource "azurerm_app_service_virtual_network_swift_connection" "fn-vnet-swift" {
  app_service_id = azurerm_windows_function_app.func.id
  subnet_id      = var.azurerm_app_service_virtual_network_swift_connection_subnet_id
}
