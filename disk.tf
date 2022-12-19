#
# Data
#

resource "azurerm_managed_disk" "data_01" {
  count = var.data_disk_size > 0 ? var.instances : 0

  name                 = azurecaf_name.vm_data_disk_01[count.index].result
  resource_group_name  = azurerm_resource_group.vm_rg.name
  location             = azurerm_resource_group.vm_rg.location
  storage_account_type = var.data_disk_type

  create_option = "Empty"
  disk_size_gb  = var.data_disk_size
  zone          = var.deploy_in_availability_set == false ? (count.index + 1) : null # TODO: Note that this will break if you deploy more than 3 VMs, but I never do that.

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_01" {
  count = var.data_disk_size > 0 ? var.instances : 0

  managed_disk_id    = azurerm_managed_disk.data_01[count.index].id
  virtual_machine_id = local.is_windows_or_windows_server == true ? azurerm_windows_virtual_machine.vm[count.index].id : azurerm_linux_virtual_machine.vm[count.index].id
  lun                = "10"
  caching            = var.data_disk_caching
}

#
# Shared
#

resource "azurerm_managed_disk" "shared_01" {
  count = var.shared_data_disk_size > 0 ? 1 : 0

  name                 = azurecaf_name.vm_data_disk_01[count.index].result
  resource_group_name  = azurerm_resource_group.vm_rg.name
  location             = azurerm_resource_group.vm_rg.location
  storage_account_type = var.shared_disk_type
  create_option        = "Empty"
  max_shares           = var.instances # See for limits: https://learn.microsoft.com/en-us/azure/virtual-machines/disks-shared-enable?tabs=azure-powershell#standard-ssd-ranges
  disk_size_gb         = var.shared_data_disk_size
  zone                 = var.deploy_in_availability_set == false ? count.index : null # TODO: Note that this will break if you deploy more than 3 VMs, but I never do that.

  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "shared_01" {
  count = var.shared_data_disk_size > 0 ? var.instances : 0

  managed_disk_id    = azurerm_managed_disk.shared_01[0].id
  virtual_machine_id = local.is_windows_or_windows_server == true ? azurerm_windows_virtual_machine.vm[count.index].id : azurerm_linux_virtual_machine.vm[count.index].id
  lun                = "10"
  caching            = var.shared_disk_caching
}
