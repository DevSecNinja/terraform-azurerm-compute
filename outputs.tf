output "vm" {
  value = local.is_windows_or_windows_server ? azurerm_windows_virtual_machine.vm[*] : azurerm_linux_virtual_machine.vm[*]
}

output "vm_nic" {
  value = azurerm_network_interface.vm_nic
}

output "vm_rg" {
  value = azurerm_resource_group.vm_rg
}

output "vm_pip" {
  value = var.deploy_public_ip_address ? azurerm_public_ip.vm_pip[*] : null
}

output "vm_identity" {
  value = local.is_windows_or_windows_server ? azurerm_windows_virtual_machine.vm[*].identity : azurerm_linux_virtual_machine.vm[*].identity
}

output "vm_lb" {
  value = var.deploy_load_balancer ? azurerm_lb.vm : null
}

output "vm_lb_pip" {
  value = var.deploy_load_balancer && var.load_balancer_is_public == true ? azurerm_public_ip.lb_pip : null
}
