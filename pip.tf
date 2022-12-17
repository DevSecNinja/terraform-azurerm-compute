resource "azurerm_public_ip" "vm_pip" {
  count = var.deploy_public_ip_address ? var.instances : 0

  name                = azurecaf_name.vm[count.index].results["azurerm_public_ip"]
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  allocation_method   = "Static"
  sku                 = var.deploy_in_availability_set == false ? "Standard" : "Basic"
  tags                = local.tags

  zones = [] # TODO: Dynamically gather the VM zones. Something like azurerm_virtual_machine.vm[*].zone doesn't work
}

resource "azurerm_public_ip" "lb_pip" {
  count = var.deploy_load_balancer && var.load_balancer_is_public == true ? 1 : 0

  name                = azurecaf_name.vm_single.results["azurerm_public_ip"]
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags

  zones = [] # TODO: Dynamically gather the VM zones. Something like azurerm_virtual_machine.vm[*].zone doesn't work
}
