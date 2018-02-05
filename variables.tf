# ==============================================================================
# Provider
# ==============================================================================

provider "azurerm" {
    subscription_id = "***-***-***-***-***"
    client_id       = "***-***-***-***-***"
    client_secret   = "***-***-***-***-***"
    tenant_id       = "***-***-***-***-***"
}

# ==============================================================================
# Project and environment
# ==============================================================================

variable "project" {
  default = "unicorn"
}

variable "resourcegroupname" {
  default = "unicorndemoazure"
}

variable "location" {
  default = "West Europe"
}

variable "tag_enviroment" {
  default = "Unicorn Demo"
}

variable "env" {
  default = "demo"

}

# ==============================================================================
# Network
# ==============================================================================


variable "net_name" {
  default = {
      "0" = "mgmt"
      "1" = "app"
      "2" = "common"
  }
}

variable "cidr" {
  default = "100.10.0.0/16"
}

variable "newbits" {
  description = "see https://www.terraform.io/docs/configuration/interpolation.html#cidrsubnet_iprange_newbits_netnum_"
  default     = 8
}

variable "netnum" {
  description = "first number of subnet to start of (ex I want a 10.1,10.2,10.3 subnet I specify 1) https://www.terraform.io/docs/configuration/interpolation.html#cidrsubnet_iprange_newbits_netnum_"
  default     = 0
}

# ==============================================================================
# Security
# ==============================================================================

variable "sec_name" {
  default = {
      "0" = "mgmt"
      "1" = "app"
      "2" = "common"
  }
}

variable "os_user" {
  default     = "vmadmin"
}

variable "os_pass" {
  default     = "***"
}

# ==============================================================================
# VM Global
# ==============================================================================

variable "publisher" {
  default = "Canonical"
}

variable "offer" {
  default = "UbuntuServer"
}

variable "sku" {
  default = "16.04.0-LTS"
}

variable "version" {
  default = "latest"
}

variable "vm_size" {
  default = "Standard_D1_v2"
}

# ==============================================================================
# VM mgmnt
# ==============================================================================

variable "mgmt_vm_n" {
  default = "1"
}

variable "app_vm_n" {
  default = "3"
}

variable "common_vm_n" {
  default = "1"
}
