# Azure Virtual Machine Terraform Module

This Terraform module allows you to easily create one or more Virtual Machines (VMs) in Azure.

## 📌 Features

- Creates a new Azure resource group
- Creates one or more VMs within the resource group
- Allows you to specify the VM size, OS, and other details

## 🔧 Usage

To use this module, you will need to have an Azure account and access to the Azure CLI with Terraform installed.
I heavily rely on the [terraform-azurerm-caf-enterprise-scale](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale) and the [terraform-azurerm-lz-vending](https://github.com/Azure/terraform-azurerm-lz-vending) modules, hence some of the references to e.g. the management & connectivity subscriptions.

> **_NOTE:_** I always suggest to use the `ref` argument to select a specific version.

```` terraform
module "k3s" {
  source = "github.com/DevSecNinja/terraform-azurerm-compute?ref=v1.0.0"

  ### Important
  instances = 3
  config    = local.config # I will soon open source my main repository under https://github.com/DevSecNinja/AzureEnvironment that provides the schema
  purpose   = "k3s"
  subnet_id = "/subscriptions/${data.azurerm_client_config.jeanpaulv-lz-corp-gen.subscription_id}/resourceGroups/${local.config.generic.org.root_id}-connectivity-${local.config.generic.regions.primaryRegion.name}/providers/Microsoft.Network/virtualNetworks/${local.config.generic.org.root_id}-spoke-lz-0-${local.config.generic.regions.primaryRegion.name}/subnets/snet-workload"
  os_type   = "linux"
  tags      = local.tags

  ## Optional
  location                 = local.config.generic.regions.primaryRegion.name
  install_oms_agent        = true
  vm_size                  = local.config.compute.virtualMachines.linux.settings.size
  enable_jit               = local.config.compute.virtualMachines.linux.just-in-time.enabled
  deploy_public_ip_address = false
  shutdown_policy_enabled  = "true"
  dns_host_record          = "k3s"
  join_in_aad              = true
  disable_backup           = true
  data_disk_size           = 32
  deploy_load_balancer     = true

  providers = {
    azurerm              = azurerm.lz-corp-gen # To deploy your resources
    azurerm.management   = azurerm.management # To access the Log Analytics workspace
    azurerm.connectivity = azurerm.connectivity # To create a DNS record
  }
}
````

## 📝 Note

After I built this module, I discovered that there is also a [nice module created by the Azure team](https://github.com/Azure/terraform-azurerm-compute) which is officially supported by Microsoft. You might want to start with that one first.

## 🤝 Contributions

I welcome contributions to this project! If you have an idea for a feature or improvement, please open an issue or pull request. If you find this project helpful, I would also appreciate it if you could leave a star on the GitHub repository 🌟

Thank you for considering contributing 🙏

## 📜 License

This project is licensed under the MIT License. It is not affiliated with my employer.

Feel free to use and modify the code as you see fit 🎉

## 📄 Terraform Documentation

I'm using `terraform-docs` to update my documentation automatically:

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | 2.0.0-preview3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.29.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.4.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurecaf"></a> [azurecaf](#provider\_azurecaf) | 2.0.0-preview3 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.29.1 |
| <a name="provider_azurerm.connectivity"></a> [azurerm.connectivity](#provider\_azurerm.connectivity) | >= 3.29.1 |
| <a name="provider_azurerm.management"></a> [azurerm.management](#provider\_azurerm.management) | >= 3.29.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurecaf_name.vm](https://registry.terraform.io/providers/aztfmod/azurecaf/2.0.0-preview3/docs/resources/name) | resource |
| [azurecaf_name.vm_data_disk_01](https://registry.terraform.io/providers/aztfmod/azurecaf/2.0.0-preview3/docs/resources/name) | resource |
| [azurecaf_name.vm_dns_name](https://registry.terraform.io/providers/aztfmod/azurecaf/2.0.0-preview3/docs/resources/name) | resource |
| [azurecaf_name.vm_shared_disk](https://registry.terraform.io/providers/aztfmod/azurecaf/2.0.0-preview3/docs/resources/name) | resource |
| [azurecaf_name.vm_single](https://registry.terraform.io/providers/aztfmod/azurecaf/2.0.0-preview3/docs/resources/name) | resource |
| [azurerm_availability_set.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |
| [azurerm_dev_test_global_vm_shutdown_schedule.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_test_global_vm_shutdown_schedule) | resource |
| [azurerm_dns_a_record.vm_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_lb.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.ssh-inbound-probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.data_01](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_managed_disk.shared_01](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.vm_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_backend_address_pool_association.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_proximity_placement_group.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/proximity_placement_group) | resource |
| [azurerm_public_ip.lb_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.vm_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.vm_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group_policy_exemption.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_exemption) | resource |
| [azurerm_resource_group_policy_exemption.ip_forwarding](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_exemption) | resource |
| [azurerm_security_center_server_vulnerability_assessment_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_server_vulnerability_assessment_virtual_machine) | resource |
| [azurerm_virtual_machine_data_disk_attachment.data_01](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_data_disk_attachment.shared_01](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.avd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.domain_join_azuread](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.vm_amaagent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.vm_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.vm_windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [random_password.vm_password](https://registry.terraform.io/providers/hashicorp/random/3.4.3/docs/resources/password) | resource |
| [time_sleep.wait_60_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_client_config.core](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_log_analytics_workspace.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_avd_extension"></a> [avd\_extension](#input\_avd\_extension) | Installs the Azure Virtual Desktop extension | `map` | <pre>{<br>  "aadJoin": true,<br>  "enabled": false,<br>  "hostPoolName": null,<br>  "registrationInfoToken": null<br>}</pre> | no |
| <a name="input_config"></a> [config](#input\_config) | Provide the decoded data from the files in generic/json/config | `any` | n/a | yes |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | Base64encoded string of the custom data config | `string` | `null` | no |
| <a name="input_custom_script_extension"></a> [custom\_script\_extension](#input\_custom\_script\_extension) | Installs the specified custom script extension. Script should be a base64encoded string | `map` | <pre>{<br>  "enabled": false,<br>  "name": null,<br>  "script": null<br>}</pre> | no |
| <a name="input_data_disk_caching"></a> [data\_disk\_caching](#input\_data\_disk\_caching) | Specify the caching setting for the data disk | `string` | `"ReadWrite"` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Deploys a data disk if size is >0 | `number` | `0` | no |
| <a name="input_data_disk_type"></a> [data\_disk\_type](#input\_data\_disk\_type) | Specify the disk type for the data disk | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_deploy_in_availability_set"></a> [deploy\_in\_availability\_set](#input\_deploy\_in\_availability\_set) | Instead of using Availability Zones (99.99% SLA - DC failure protection), the VMs will be deployed in an Availability Set (99.9% SLA - 'rack failure' protection). | `bool` | `false` | no |
| <a name="input_deploy_load_balancer"></a> [deploy\_load\_balancer](#input\_deploy\_load\_balancer) | Deploys a load balancer and adds the network interfaces to the backend pool | `bool` | `false` | no |
| <a name="input_deploy_public_ip_address"></a> [deploy\_public\_ip\_address](#input\_deploy\_public\_ip\_address) | n/a | `bool` | `false` | no |
| <a name="input_disable_backup"></a> [disable\_backup](#input\_disable\_backup) | Requests a policy exemption for backups on the VM in the Resource Group | `bool` | `false` | no |
| <a name="input_dns_host_record"></a> [dns\_host\_record](#input\_dns\_host\_record) | DNS Host record will only be set when deploying a public IP address | `bool` | `false` | no |
| <a name="input_enable_ip_forwarding"></a> [enable\_ip\_forwarding](#input\_enable\_ip\_forwarding) | n/a | `bool` | `false` | no |
| <a name="input_enable_jit"></a> [enable\_jit](#input\_enable\_jit) | Enables Just-in-Time Administration | `bool` | `false` | no |
| <a name="input_install_oms_agent"></a> [install\_oms\_agent](#input\_install\_oms\_agent) | Installs the OMS Agent | `bool` | `false` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Specify the number of VM instances | `number` | `1` | no |
| <a name="input_join_in_aad"></a> [join\_in\_aad](#input\_join\_in\_aad) | Joins the machine in Azure Active Directory | `bool` | `true` | no |
| <a name="input_load_balancer_health_probe_port"></a> [load\_balancer\_health\_probe\_port](#input\_load\_balancer\_health\_probe\_port) | Health probe port, default is 22 for Linux and 3389 for Windows | `number` | `0` | no |
| <a name="input_load_balancer_is_public"></a> [load\_balancer\_is\_public](#input\_load\_balancer\_is\_public) | If true, a Public IP address will be created and associated | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Provide the Azure region | `string` | `"westeurope"` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Specify the Operating System time | `string` | `"windows_server"` | no |
| <a name="input_purpose"></a> [purpose](#input\_purpose) | Purpose is used in the naming of the VM | `any` | n/a | yes |
| <a name="input_shared_data_disk_size"></a> [shared\_data\_disk\_size](#input\_shared\_data\_disk\_size) | Deploys a shared data disk if size is >0 | `number` | `0` | no |
| <a name="input_shared_disk_caching"></a> [shared\_disk\_caching](#input\_shared\_disk\_caching) | Specify the caching setting for the shared disk | `string` | `"ReadWrite"` | no |
| <a name="input_shared_disk_type"></a> [shared\_disk\_type](#input\_shared\_disk\_type) | Specify the disk type for the shared disk | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_shutdown_policy_enabled"></a> [shutdown\_policy\_enabled](#input\_shutdown\_policy\_enabled) | n/a | `string` | `"true"` | no |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | n/a | `map(string)` | <pre>{<br>  "offer": null,<br>  "publisher": null,<br>  "sku": null,<br>  "version": null<br>}</pre> | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Provide the ID of the subnet that the VM should use | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | n/a | `string` | `"Standard_B2s"` | no |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | Provide the Log Analytics Workspace ID for the VM to report data to | `any` | `null` | no |
| <a name="input_workspace_key"></a> [workspace\_key](#input\_workspace\_key) | Provide the Log Analytics Workspace key for the VM to report data to | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm"></a> [vm](#output\_vm) | n/a |
| <a name="output_vm_identity"></a> [vm\_identity](#output\_vm\_identity) | n/a |
| <a name="output_vm_lb"></a> [vm\_lb](#output\_vm\_lb) | n/a |
| <a name="output_vm_nic"></a> [vm\_nic](#output\_vm\_nic) | n/a |
| <a name="output_vm_rg"></a> [vm\_rg](#output\_vm\_rg) | n/a |
<!-- END_TF_DOCS -->
