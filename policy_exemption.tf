resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}

resource "azurerm_resource_group_policy_exemption" "ip_forwarding" {
  count = var.enable_ip_forwarding ? 1 : 0

  name                 = "AllowIPForwarding"
  display_name         = "Allow IP Forwarding for VM"
  resource_group_id    = azurerm_resource_group.vm_rg.id
  policy_assignment_id = "/providers/microsoft.management/managementgroups/${var.config.generic.org.root_id}-landing-zones/providers/microsoft.authorization/policyassignments/deny-ip-forwarding"
  exemption_category   = "Waiver"
}

resource "azurerm_resource_group_policy_exemption" "backup" {
  count = var.disable_backup ? 0 : 1

  name                 = "DisableBackups"
  display_name         = "Disable backups on VMs in the '${azurerm_resource_group.vm_rg.name}' Resource Group"
  resource_group_id    = azurerm_resource_group.vm_rg.id
  policy_assignment_id = "/providers/microsoft.management/managementgroups/${var.config.generic.org.root_id}-landing-zones/providers/microsoft.authorization/policyassignments/deploy-vm-backup"
  exemption_category   = "Waiver"
}
