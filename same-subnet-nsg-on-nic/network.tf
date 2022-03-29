resource "azurerm_network_security_group" "nsg" {
  name                = local.fqrn
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.fqrn
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.139.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "asg_subnet" {
  name                 = "asg-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.139.0.0/18"]
}

resource "azurerm_network_interface_security_group_association" "asg1_nic_nsg" {
  network_interface_id      = azurerm_network_interface.asg1_vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "asg2_nic_nsg" {
  network_interface_id      = azurerm_network_interface.asg2_vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "asg3_nic_nsg" {
  network_interface_id      = azurerm_network_interface.asg3_vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_security_rule" "asg-public-rule" {
  name                                       = "asg-public-rule"
  priority                                   = 100
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = "22"
  source_address_prefixes                    = ["24.31.171.98"]
  destination_application_security_group_ids = [azurerm_application_security_group.asg1.id]
  resource_group_name                        = azurerm_resource_group.rg.name
  network_security_group_name                = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "asg_deny_to_asg2" {
  name                                       = "asg-deny-to-asg2"
  priority                                   = 110
  direction                                  = "Inbound"
  access                                     = "Deny"
  protocol                                   = "*"
  source_port_range                          = "*"
  destination_port_range                     = "*"
  source_application_security_group_ids      = [azurerm_application_security_group.asg1.id]
  destination_application_security_group_ids = [azurerm_application_security_group.asg2.id]
  resource_group_name                        = azurerm_resource_group.rg.name
  network_security_group_name                = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "asg_allow_to_asg3" {
  name                                       = "asg-allow-to-asg3"
  priority                                   = 120
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "*"
  source_port_range                          = "*"
  destination_port_range                     = "*"
  source_application_security_group_ids      = [azurerm_application_security_group.asg1.id]
  destination_application_security_group_ids = [azurerm_application_security_group.asg3.id]
  resource_group_name                        = azurerm_resource_group.rg.name
  network_security_group_name                = azurerm_network_security_group.nsg.name
}