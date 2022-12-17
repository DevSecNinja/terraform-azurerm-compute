#
# Custom Script Extension
#

# Linux
resource "azurerm_virtual_machine_extension" "vm_linux" {
  count = var.custom_script_extension.enabled && local.is_linux ? var.instances : 0

  name                 = var.custom_script_extension.name
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${var.custom_script_extension.script}"
    }
SETTINGS
}

# Windows
resource "azurerm_virtual_machine_extension" "vm_windows" {
  count = var.custom_script_extension.enabled && local.is_linux != true ? var.instances : 0

  name                 = var.custom_script_extension.name
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings  = <<PROTECTEDSETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -encodedCommand ${var.custom_script_extension.script}"
    }
PROTECTEDSETTINGS
}

# Azure Virtual Desktop
# Despite the other VM extension taking care of the Azure AD Join, we have to specify the property here too.
resource "azurerm_virtual_machine_extension" "avd" {
  count = var.avd_extension.enabled && local.is_linux != true ? var.instances : 0

  name                       = "AzureVirtualDesktopSessionHost"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"

  settings = <<-SETTINGS
    {
      "modulesUrl": "${var.config.compute.virtualMachines.azure_virtual_desktop.config.agentUrl}",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${var.avd_extension.hostPoolName}",
        "aadJoin": ${var.avd_extension.aadJoin}
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${var.avd_extension.registrationInfoToken}"
    }
  }
PROTECTED_SETTINGS
}