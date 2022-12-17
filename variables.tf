variable "os_type" {
  description = "Specify the Operating System time"
  default     = "windows_server"
  validation {
    condition     = contains(["windows", "windows_server", "linux"], var.os_type)
    error_message = "Provide a valid value."
  }
}

variable "location" {
  description = "Provide the Azure region"
  default     = "westeurope"
}

variable "purpose" {
  description = "Purpose is used in the naming of the VM"

  validation {
    condition     = length(var.purpose) < 7
    error_message = "The purpose value must not exceed 6 characters."
  }
}

variable "subnet_id" {
  description = "Provide the ID of the subnet that the VM should use"
}

variable "vm_size" {
  default = "Standard_B2s"
}

variable "workspace_id" {
  description = "Provide the Log Analytics Workspace ID for the VM to report data to"
  default     = null
}

variable "workspace_key" {
  description = "Provide the Log Analytics Workspace key for the VM to report data to"
  default     = null
}

variable "enable_jit" {
  description = "Enables Just-in-Time Administration"
  default     = false
}

variable "shutdown_policy_enabled" {
  default = "true" # Cannot be bool. TODO: Convert bool to string in TF file
}

variable "deploy_public_ip_address" {
  default = false
}

variable "dns_host_record" {
  description = "DNS Host record will only be set when deploying a public IP address"

  # This would have been nice...
  # validation {
  #   condition     = var.deploy_public_ip_address == true
  #   error_message = "DNS Host record cannot be set without deploying a public IP address. Set 'deploy_public_ip_address' to true or unset this variable"
  # }

  default = false
}

variable "install_oms_agent" {
  description = "Installs the OMS Agent"
  default     = false
}

variable "enable_ip_forwarding" {
  default = false
}

variable "custom_data" {
  type        = string
  default     = null
  description = "Base64encoded string of the custom data config"
}

variable "source_image_reference" {
  type = map(string)

  default = {
    publisher = null
    offer     = null
    sku       = null
    version   = null
  }
}

variable "join_in_aad" {
  default     = true
  description = "Joins the machine in Azure Active Directory"
}

variable "instances" {
  description = "Specify the number of VM instances"
  type        = number
  default     = 1
  validation {
    condition     = var.instances < 4
    error_message = "Currently not possible to deploy more than 3 VMs due to the availability zones config on the VM"
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "config" {
  description = "Provide the decoded data from the files in generic/json/config"
}

variable "deploy_in_availability_set" {
  description = "Instead of using Availability Zones (99.99% SLA - DC failure protection), the VMs will be deployed in an Availability Set (99.9% SLA - 'rack failure' protection)."
  default     = false
}

variable "data_disk_size" {
  description = "Deploys a data disk if size is >0"
  validation {
    condition     = contains([0, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048], var.data_disk_size)
    error_message = "Provide a valid value."
  }
  default = 0
}

variable "data_disk_caching" {
  description = "Specify the caching setting for the data disk"
  default     = "ReadWrite"
  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.data_disk_caching)
    error_message = "Provide a valid value."
  }
}

variable "disable_backup" {
  description = "Requests a policy exemption for backups on the VM in the Resource Group"
  default     = false
}

variable "shared_data_disk_size" {
  description = "Deploys a shared data disk if size is >0"
  validation {
    condition     = contains([0, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048], var.shared_data_disk_size)
    error_message = "Provide a valid value."
  }
  default = 0
}

variable "shared_disk_caching" {
  description = "Specify the caching setting for the shared disk"
  default     = "ReadWrite"
  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.shared_disk_caching)
    error_message = "Provide a valid value."
  }
}

variable "deploy_load_balancer" {
  description = "Deploys a load balancer and adds the network interfaces to the backend pool"
  default     = false
}

variable "load_balancer_health_probe_port" {
  description = "Health probe port, default is 22 for Linux and 3389 for Windows"
  default     = 0
}

variable "load_balancer_is_public" {
  description = "If true, a Public IP address will be created and associated"
  default     = false
}

variable "custom_script_extension" {
  description = "Installs the specified custom script extension. Script should be a base64encoded string"
  default = {
    enabled = false
    name = null
    script = null
  }
}