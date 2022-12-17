#
# Custom Script Extension
#

# Linux
resource "azurerm_virtual_machine_extension" "vm" {
  count = var.custom_script_extension.name && var.custom_script_extension.script && local.is_linux ? var.instances : 0

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
resource "azurerm_virtual_machine_extension" "vm" {
  count = var.custom_script_extension.name && var.custom_script_extension.script && local.is_linux != true ? var.instances : 0

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