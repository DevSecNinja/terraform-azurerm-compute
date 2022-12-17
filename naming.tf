#
# CAF Naming
#

resource "azurecaf_name" "vm" {
  count = var.instances

  resource_type  = "azurerm_virtual_machine"
  resource_types = ["azurerm_network_interface", "azurerm_managed_disk", "azurerm_proximity_placement_group", "azurerm_public_ip"]
  prefixes       = []
  suffixes       = [local.os_type_short, var.purpose, (count.index + 1)]
  clean_input    = true
}

resource "azurecaf_name" "vm_single" {
  resource_types = ["azurerm_availability_set", "azurerm_resource_group", "azurerm_lb", "azurerm_public_ip"]
  prefixes       = []
  suffixes       = [local.os_type_short, var.purpose]
  clean_input    = true
}

resource "azurecaf_name" "vm_data_disk_01" {
  count = var.instances

  resource_type = "azurerm_managed_disk"
  prefixes      = []
  suffixes      = [local.os_type_short, var.purpose, (count.index + 1), "data", 01]
  clean_input   = true
}

resource "azurecaf_name" "vm_dns_name" {
  count = var.dns_host_record != false ? var.instances : 0

  resource_type = "general"
  prefixes      = []
  suffixes      = [local.os_type_short, var.dns_host_record, (count.index + 1)]
  clean_input   = true
}

resource "azurecaf_name" "vm_shared_disk" {
  count = var.shared_data_disk_size > 0 ? 1 : 0

  resource_type = "azurerm_managed_disk"
  prefixes      = []
  suffixes      = [var.dns_host_record, "shared"]
  clean_input   = true
}
