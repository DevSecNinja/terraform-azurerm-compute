resource "azurerm_resource_group" "vm_rg" {
  name     = azurecaf_name.vm_single.results["azurerm_resource_group"]
  location = var.location
  tags     = local.tags
}
