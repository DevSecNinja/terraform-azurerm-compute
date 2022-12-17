locals {
  law_name      = "${var.config.generic.org.root_id}-la"
  rsg_mgmt_name = "${var.config.generic.org.root_id}-mgmt"
}

#
# Log Analytics
#

data "azurerm_log_analytics_workspace" "law" {
  name                = local.law_name
  resource_group_name = local.rsg_mgmt_name
  provider            = azurerm.management
}
