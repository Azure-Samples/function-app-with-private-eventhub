resource "azurerm_app_service_plan" "plan" {
  name                = var.azurerm_app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  reserved            = false
  kind                = "elastic"

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }

  lifecycle {
    ignore_changes = [
      kind
    ]
  }
}

resource "azurerm_function_app" "func" {
  name                       = var.azurerm_function_app_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = var.azurerm_function_app_storage_account_name
  storage_account_access_key = var.azurerm_function_app_storage_account_access_key
  version                    = "~3"
  enable_builtin_logging     = false
  app_settings               = merge(local.app_settings, var.azurerm_function_app_app_settings, local.windows_only_app_settings)

  site_config {
    pre_warmed_instance_count        = 1
    runtime_scale_monitoring_enabled = true
    vnet_route_all_enabled           = true
    ftps_state                       = "Disabled"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "fn-vnet-swift" {
  app_service_id = azurerm_function_app.func.id
  subnet_id      = var.azurerm_app_service_virtual_network_swift_connection_subnet_id
}

locals {
  # terraform auto provisions AzureWebJobsStorage and WEBSITE_CONTENTAZUREFILECONNECTIONSTRING, which cannot be overridden
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = var.functions_worker_runtime
    APPINSIGHTS_INSTRUMENTATIONKEY = var.azurerm_function_app_appinsights_instrumentation_key
  }
  # terraform auto provisions AzureWebJobsStorage and WEBSITE_CONTENTAZUREFILECONNECTIONSTRING, which cannot be overridden
  windows_only_app_settings = {
    WEBSITE_CONTENTOVERVNET = 1
  }
}
