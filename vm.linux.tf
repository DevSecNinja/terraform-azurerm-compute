resource "azurerm_linux_virtual_machine" "vm" {
  count = local.is_linux ? var.instances : 0

  name                            = azurecaf_name.vm[count.index].result
  resource_group_name             = azurerm_resource_group.vm_rg.name
  location                        = azurerm_resource_group.vm_rg.location
  size                            = var.vm_size
  admin_username                  = var.config.compute.virtualMachines.linux.settings.osProfile.adminUsername
  admin_password                  = random_password.vm_password[count.index].result
  disable_password_authentication = var.config.compute.virtualMachines.linux.settings.disable_password_authentication
  network_interface_ids = [
    azurerm_network_interface.vm_nic[count.index].id,
  ]
  computer_name = azurecaf_name.vm[count.index].result
  custom_data   = try(var.custom_data, null)
  tags          = local.tags

  zone                         = var.deploy_in_availability_set == false ? (count.index + 1) : null # TODO: Note that this will break if you deploy more than 3 VMs, but I never do that.
  proximity_placement_group_id = var.instances > 1 ? azurerm_proximity_placement_group.vm[count.index].id : null
  availability_set_id          = var.instances > 1 && var.deploy_in_availability_set == true ? azurerm_availability_set.vm[0].id : null

  dynamic "admin_ssh_key" {
    for_each = var.config.compute.virtualMachines.linux.ssh_pub_keys
    content {
      username   = var.config.compute.virtualMachines.linux.settings.osProfile.adminUsername
      public_key = admin_ssh_key.value
    }
  }

  boot_diagnostics {}

  identity {
    type = var.config.compute.virtualMachines.linux.settings.identity.type
  }

  os_disk {
    name                 = azurecaf_name.vm[count.index].results["azurerm_managed_disk"]
    disk_size_gb         = var.config.compute.virtualMachines.linux.settings.storageProfile.osDisk.size
    caching              = var.config.compute.virtualMachines.linux.settings.storageProfile.osDisk.caching
    storage_account_type = var.config.compute.virtualMachines.linux.settings.storageProfile.osDisk.managedDisk.storageAccountType
  }

  source_image_reference {
    publisher = try(length(var.source_image_reference.publisher), 0) > 0 ? var.source_image_reference.publisher : var.config.compute.virtualMachines.linux.settings.storageProfile.imageReference.publisher
    offer     = try(length(var.source_image_reference.offer), 0) > 0 ? var.source_image_reference.offer : var.config.compute.virtualMachines.linux.settings.storageProfile.imageReference.offer
    sku       = try(length(var.source_image_reference.sku), 0) > 0 ? var.source_image_reference.sku : var.config.compute.virtualMachines.linux.settings.storageProfile.imageReference.sku
    version   = try(length(var.source_image_reference.version), 0) > 0 ? var.source_image_reference.version : var.config.compute.virtualMachines.linux.settings.storageProfile.imageReference.version
  }

  # Enable Just-in-Time Administration
  provisioner "local-exec" {
    when        = create
    command     = <<EOT
    if (${var.enable_jit}) {
      Set-AzContext -SubscriptionId "${data.azurerm_client_config.core.subscription_id}"
      $JitPolicy = (@{ id="${self.id}"
        ports=(@{
            number=22;
            protocol="*";
            allowedSourceAddressPrefix=@("*");
            maxRequestAccessDuration="${var.config.compute.virtualMachines.linux.just-in-time.policy.maxRequestAccessDuration}"},
            @{
            number=3389;
            protocol="*";
            allowedSourceAddressPrefix=@("*");
            maxRequestAccessDuration="${var.config.compute.virtualMachines.linux.just-in-time.policy.maxRequestAccessDuration}"})})
        $JitPolicyArr=@($JitPolicy)
        Set-AzJitNetworkAccessPolicy -Kind "Basic" -Location "${self.location}" -Name "${self.name}" -ResourceGroupName "${self.resource_group_name}" -VirtualMachine $JitPolicyArr -ErrorAction SilentlyContinue
    }
   EOT
    interpreter = ["pwsh", "-NoProfile", "-NonInteractive", "-NoLogo", "-Command"]
  }

  depends_on = [
    azurerm_resource_group_policy_exemption.backup,
    time_sleep.wait_30_seconds # Needed for the policy exemption to become active
  ]
}
