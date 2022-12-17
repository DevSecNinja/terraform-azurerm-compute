resource "azurerm_security_center_server_vulnerability_assessment_virtual_machine" "vm" {
  count = var.instances

  virtual_machine_id = local.is_windows_or_windows_server ? azurerm_windows_virtual_machine.vm[count.index].id : azurerm_linux_virtual_machine.vm[count.index].id
  depends_on = [
    azurerm_virtual_machine_extension.docker,
    azurerm_virtual_machine_extension.vm_amaagent,
    azurerm_virtual_machine_extension.domain_join_azuread
  ]
}
