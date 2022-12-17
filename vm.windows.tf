resource "azurerm_windows_virtual_machine" "vm" {
  count = local.is_windows_or_windows_server ? var.instances : 0

  name                = azurecaf_name.vm[count.index].result
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  size                = var.vm_size
  admin_username      = local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.osProfile.adminUsername : var.config.compute.virtualMachines.windows.settings.osProfile.adminUsername
  admin_password      = random_password.vm_password[count.index].result
  network_interface_ids = [
    azurerm_network_interface.vm_nic[count.index].id,
  ]
  computer_name            = azurecaf_name.vm[count.index].result
  custom_data              = try(var.custom_data, null)
  enable_automatic_updates = local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.osProfile.windowsConfiguration.enableAutomaticUpdates : var.config.compute.virtualMachines.windows.settings.osProfile.windowsConfiguration.enableAutomaticUpdates
  patch_mode               = local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.osProfile.windowsConfiguration.patchSettings.patchMode : var.config.compute.virtualMachines.windows.settings.osProfile.windowsConfiguration.patchSettings.patchMode
  provision_vm_agent       = local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.osProfile.windowsConfiguration.provisionVMAgent : var.config.compute.virtualMachines.windows.settings.osProfile.windowsConfiguration.provisionVMAgent
  timezone                 = local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.osProfile.windowsConfiguration.timezone : var.config.compute.virtualMachines.windows.settings.osProfile.windowsConfiguration.timezone
  tags                     = local.tags

  zone                         = var.deploy_in_availability_set == false ? (count.index + 1) : null # TODO: Note that this will break if you deploy more than 3 VMs, but I never do that.
  proximity_placement_group_id = var.instances > 1 ? azurerm_proximity_placement_group.vm[count.index].id : null
  availability_set_id          = var.instances > 1 && var.deploy_in_availability_set == true ? azurerm_availability_set.vm[0].id : null

  boot_diagnostics {}

  identity {
    type = local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.identity.type : var.config.compute.virtualMachines.windows.settings.identity.type
  }

  os_disk {
    name                 = azurecaf_name.vm[count.index].results["azurerm_managed_disk"]
    caching              = local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.storageProfile.osDisk.caching : var.config.compute.virtualMachines.windows.settings.storageProfile.osDisk.caching
    storage_account_type = local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.storageProfile.osDisk.managedDisk.storageAccountType : var.config.compute.virtualMachines.windows.settings.storageProfile.osDisk.managedDisk.storageAccountType
  }

  source_image_reference {
    publisher = try(length(var.source_image_reference.publisher), 0) > 0 ? var.source_image_reference.publisher : local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.storageProfile.imageReference.publisher : var.config.compute.virtualMachines.windows.settings.storageProfile.imageReference.publisher
    offer     = try(length(var.source_image_reference.offer), 0) > 0 ? var.source_image_reference.offer : local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.storageProfile.imageReference.offer : var.config.compute.virtualMachines.windows.settings.storageProfile.imageReference.offer
    sku       = try(length(var.source_image_reference.sku), 0) > 0 ? var.source_image_reference.sku : local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.storageProfile.imageReference.sku : var.config.compute.virtualMachines.windows.settings.storageProfile.imageReference.sku
    version   = try(length(var.source_image_reference.version), 0) > 0 ? var.source_image_reference.version : local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.settings.storageProfile.imageReference.version : var.config.compute.virtualMachines.windows.settings.storageProfile.imageReference.version
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
            maxRequestAccessDuration="${local.is_windows_server == true ? var.config.compute.virtualMachines.windowsServer.just-in-time.policy.maxRequestAccessDuration : var.config.compute.virtualMachines.windows.just-in-time.policy.maxRequestAccessDuration}"},
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
    time_sleep.wait_60_seconds # Needed for the policy exemption to become active
  ]
}
