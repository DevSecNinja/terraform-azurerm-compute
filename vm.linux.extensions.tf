#
# Docker
#

# TODO: To refactor based on filename input in var

data "local_file" "install_docker" {
  filename = "${path.module}/../../../../../generic/scripts/bash/Install-Docker.sh"
}

resource "azurerm_virtual_machine_extension" "docker" {
  count = var.install_docker && local.is_linux ? var.instances : 0

  name                 = "InstallDocker"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "${base64encode(data.local_file.install_docker.content)}"
    }
SETTINGS
}
