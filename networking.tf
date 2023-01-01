#
# Network Interfaces
#

resource "azurerm_network_interface" "vm_nic" {
  count = var.instances

  name                 = azurecaf_name.vm[count.index].results["azurerm_network_interface"]
  location             = azurerm_resource_group.vm_rg.location
  resource_group_name  = azurerm_resource_group.vm_rg.name
  enable_ip_forwarding = var.enable_ip_forwarding
  tags                 = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.deploy_public_ip_address ? azurerm_public_ip.vm_pip[count.index].id : null
  }

  depends_on = [
    time_sleep.wait_60_seconds # Needed for the policy exemption to become active
  ]
}

#
# DNS Records
#

resource "azurerm_dns_a_record" "vm_pip" {
  count = var.dns_host_record != false && var.deploy_public_ip_address == true ? var.instances : 0

  name                = azurecaf_name.vm_dns_name[count.index].result
  zone_name           = var.config.networking.dns.public.azure.domain
  resource_group_name = local.rsg_dns_name
  ttl                 = 60
  target_resource_id  = azurerm_public_ip.vm_pip[count.index].id
  provider            = azurerm.connectivity
}

#
# Load Balancer
#

resource "azurerm_lb" "vm" {
  count = var.deploy_load_balancer == true ? 1 : 0

  name                = azurecaf_name.vm_single.results["azurerm_lb"]
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  sku                 = var.load_balancer_is_public == true ? azurerm_public_ip.lb_pip[0].sku : "Standard" # Needs to match & we need standard for the Availability Zones
  sku_tier            = "Regional"
  tags                = local.tags

  frontend_ip_configuration {
    name                 = var.load_balancer_is_public == true ? "PublicIPAddress" : "PrivateIPAddress"
    public_ip_address_id = var.load_balancer_is_public == true ? azurerm_public_ip.lb_pip[0].id : null
    subnet_id            = var.load_balancer_is_public == true ? null : var.subnet_id
  }
}

resource "azurerm_lb_backend_address_pool" "vm" {
  count = var.deploy_load_balancer == true ? 1 : 0

  loadbalancer_id = azurerm_lb.vm[0].id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "vm" {
  count = var.deploy_load_balancer == true ? var.instances : 0

  network_interface_id    = azurerm_network_interface.vm_nic[count.index].id
  ip_configuration_name   = azurerm_network_interface.vm_nic[count.index].ip_configuration.0.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.vm[0].id
}

resource "azurerm_lb_probe" "lb-probe" {
  count = var.deploy_load_balancer == true ? 1 : 0

  loadbalancer_id = azurerm_lb.vm[0].id
  name            = "lb-inbound-probe"
  port            = var.load_balancer_health_probe_port > 0 ? var.load_balancer_health_probe_port : local.is_linux ? 22 : 3389
}
