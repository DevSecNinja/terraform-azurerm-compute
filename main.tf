terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 3.29.1"
      configuration_aliases = [azurerm, azurerm.management, azurerm.connectivity]
    }

    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "2.0.0-preview3"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

locals {
  # Get subscription data
  subs_platform_mgmt_id        = var.config.subscriptions.platform.conn.id
  subs_landing_zones_corp_id   = [for sub in var.config.subscriptions.landing_zones.corp.subscriptions : sub.id]
  subs_landing_zones_corp_name = [for sub in var.config.subscriptions.landing_zones.corp.subscriptions : sub.name]

  rsg_dns_name = "${var.config.generic.org.root_id}-dns"

  # Get the OS Type shortname
  os_type_short = var.os_type != "linux" ? "win" : "lin"

  # Set bools for validation
  is_linux          = var.os_type == "linux" ? true : false
  is_windows        = var.os_type == "windows" ? true : false
  is_windows_server = var.os_type == "windows_server" ? true : false

  is_windows_or_windows_server = local.is_windows || local.is_windows_server ? true : false

  # Tags
  tags = merge(var.tags, {
    terraformWorkspace = "compute/virtual_machine"
    vmBackupEnabled    = var.disable_backup == true ? false : true
    vmOsType           = var.os_type
  })
}

# Obtain client configuration from the un-aliased provider
data "azurerm_client_config" "core" {
  provider = azurerm
}
