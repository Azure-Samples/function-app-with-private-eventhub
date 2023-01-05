// Terraform currently (as of February 2022) does not support setting Network Access to 'Disabled' on Event Hub namespaces.
// The module offers the same functionality via the 'Selected Networks' option, restricting traffic from outside the virtual network.
// Please refer to https://github.com/hashicorp/terraform-provider-azurerm/issues/14947 for additional information.

resource "azurerm_eventhub_namespace" "evhns" {
  name                = var.azurerm_eventhub_namespace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.azurerm_eventhub_namespace_sku

  network_rulesets {
    default_action                 = "Deny"
    trusted_service_access_enabled = false
    
    virtual_network_rule {
      ignore_missing_virtual_network_service_endpoint = false
      subnet_id                                       = var.azurerm_eventhub_namespace_subnet_id
    }
  }
}

resource "azurerm_eventhub" "evh" {
  name                = var.azurerm_eventhub_name
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_eventhub_namespace.evhns.name #var.azurerm_eventhub_namespace_name
  partition_count     = var.azurerm_eventhub_partition_count
  message_retention   = var.azurerm_eventhub_message_retention
}

resource "azurerm_private_dns_zone" "evhns_private_link" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "evhns_private_link" {
  name                  = "servicebus_privatelink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.evhns_private_link.name
  virtual_network_id    = var.azurerm_private_dns_zone_virtual_network_id
}

resource "azurerm_private_endpoint" "evhns_private_endpoint" {
  name                = var.azurerm_private_endpoint_evhns_private_endpoint_name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.azurerm_private_endpoint_evhns_private_endpoint_subnet_id

  private_service_connection {
    name                           = var.azurerm_private_endpoint_evhns_private_endpoint_service_connection_name
    private_connection_resource_id = azurerm_eventhub_namespace.evhns.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "event-hub-private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.evhns_private_link.id]
  }
}
