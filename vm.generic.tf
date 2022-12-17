#
# Generic
#
resource "random_password" "vm_password" {
  count = var.instances

  length           = 24
  special          = true
  override_special = "!#$%&*-_=+:?"
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm" {
  count = var.instances

  virtual_machine_id = local.is_windows_or_windows_server == true ? azurerm_windows_virtual_machine.vm[count.index].id : azurerm_linux_virtual_machine.vm[count.index].id
  location           = azurerm_resource_group.vm_rg.location
  enabled            = var.shutdown_policy_enabled

  daily_recurrence_time = local.is_windows_or_windows_server == true ? local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.shutdownPolicy.daily_recurrence_time : var.config.compute.virtualMachines.windows.settings.shutdownPolicy.daily_recurrence_time : var.config.compute.virtualMachines.linux.settings.shutdownPolicy.daily_recurrence_time
  timezone              = local.is_windows_or_windows_server == true ? local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.shutdownPolicy.timezone : var.config.compute.virtualMachines.windows.settings.shutdownPolicy.timezone : var.config.compute.virtualMachines.linux.settings.shutdownPolicy.timezone
  notification_settings {
    enabled = local.is_windows_or_windows_server == true ? local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.shutdownPolicy.notificationEnabled : var.config.compute.virtualMachines.windows.settings.shutdownPolicy.notificationEnabled : var.config.compute.virtualMachines.linux.settings.shutdownPolicy.notificationEnabled
  }
}

resource "azurerm_virtual_machine_extension" "vm_amaagent" {
  count = var.install_oms_agent ? var.instances : 0

  name                       = local.is_linux == true ? "OmsAgentForLinux" : "AzureMonitorWindowsAgent"
  virtual_machine_id         = local.is_linux == true ? azurerm_linux_virtual_machine.vm[count.index].id : azurerm_windows_virtual_machine.vm[count.index].id
  publisher                  = local.is_linux == true ? "Microsoft.EnterpriseCloud.Monitoring" : "Microsoft.Azure.Monitor"
  type                       = local.is_linux == true ? "OmsAgentForLinux" : "AzureMonitorWindowsAgent"
  type_handler_version       = local.is_linux == true ? "1.13" : "1.2"
  auto_upgrade_minor_version = "true"
  settings                   = <<SETTINGS
    {
      "workspaceId": "${try(length(var.workspace_id), 0) > 0 ? var.workspace_id : data.azurerm_log_analytics_workspace.law.workspace_id}"
    }
SETTINGS
  protected_settings         = <<PROTECTED_SETTINGS
   {
      "workspaceKey": "${try(length(var.workspace_key), 0) > 0 ? var.workspace_key : data.azurerm_log_analytics_workspace.law.primary_shared_key}"
   }
PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "domain_join_azuread" {
  count = var.join_in_aad ? var.instances : 0

  name                       = local.is_linux == true ? "AADSSHLoginForLinux" : "AzureADJoin"
  virtual_machine_id         = local.is_linux == true ? azurerm_linux_virtual_machine.vm[count.index].id : azurerm_windows_virtual_machine.vm[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = local.is_linux == true ? "AADSSHLoginForLinux" : "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

#
# Availability Set
#

resource "azurerm_availability_set" "vm" {
  count = var.instances > 1 && var.deploy_in_availability_set == true ? 1 : 0

  name                = azurecaf_name.vm_single.results["azurerm_availability_set"]
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location

  proximity_placement_group_id = azurerm_proximity_placement_group.vm[count.index].id

  tags = local.tags
}

#
# Proximity Placement Group
#

resource "azurerm_proximity_placement_group" "vm" {
  count = var.instances > 1 ? var.instances : 0

  name                = azurecaf_name.vm[count.index].results["azurerm_proximity_placement_group"]
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location

  tags = local.tags
}
