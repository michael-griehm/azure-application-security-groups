terraform {
  required_providers {
    azuread = "~>2.16.0"
  }
}

provider "azurerm" {
  features {
  }
}

variable "app_name" {
  default   = "asg-same-subnet-nsg-on-nic"
  type      = string
  sensitive = false
}

variable "env" {
  default   = "demo"
  sensitive = false
}

variable "location" {
  default   = "East US 2"
  sensitive = false
}

variable "tags" {
  type = map(string)

  default = {
    environment = "demo"
    workload    = "asg"
  }
}

locals {
  loc            = lower(replace(var.location, " ", ""))
  a_name         = replace(var.app_name, "-", "")
  fqrn           = "${var.app_name}-${var.env}-${local.loc}"
  fqrn_no_dashes = "${local.a_name}-${var.env}-${local.loc}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = local.fqrn
  location = var.location
}