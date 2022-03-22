variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Azure resources."
}

variable "location" {
  type        = string
  description = "The Azure region for the specified resources."
}

variable "azurerm_eventhub_namespace_name" {
  type        = string
  description = "The name of the Event Hub namespace."
}

variable "azurerm_eventhub_namespace_sku" {
  type        = string
  default     = "Standard"
  description = "The Event Hub namespace tier to use."
}

variable "azurerm_eventhub_namespace_subnet_id" {
  type        = string
  description = "The virtual network subnet ID to allow access to the event hub."
}

variable "azurerm_eventhub_name" {
  type        = string
  description = "The name of the event hub."
}

variable "azurerm_eventhub_partition_count" {
  type        = number
  default     = 32
  description = "The current number of shards on the Event Hub."
}

variable "azurerm_eventhub_message_retention" {
  type        = number
  default     = 1
  description = "The number of days to retain the events for this Event Hub."
}

variable "azurerm_private_endpoint_evhns_private_endpoint_name" {
  type        = string
  description = "The name of the Event Hub namespace private endpoint."
}

variable "azurerm_private_endpoint_evhns_private_endpoint_subnet_id" {
  type        = string
  description = "The ID of the virtual network subnet from which private IP addresses will be allocated for the private endpoint."
}

variable "azurerm_private_endpoint_evhns_private_endpoint_service_connection_name" {
  type        = string
  description = "The name for the private endpoint connection for the Event Hub namespace. "
}

variable "azurerm_private_dns_zone_virtual_network_id" {
  type        = string
  description = "The ID of the virtual network that should be linked to the DNS Zone."
}
