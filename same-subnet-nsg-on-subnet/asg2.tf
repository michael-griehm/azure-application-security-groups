resource "azurerm_network_interface" "asg2_vm_nic" {
  name                = "asg2-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "asg2-vm-nic-ip"
    subnet_id                     = azurerm_subnet.asg_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "asg2_vm" {
  name                             = "asg2-vm"
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  network_interface_ids            = [azurerm_network_interface.asg2_vm_nic.id]
  vm_size                          = "Standard_b2ms"
  tags                             = var.tags
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "asg2-vm-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "asg2-vm"
    admin_username = "asg2-admin"
    admin_password = "S3cureP@ssw0rd"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_application_security_group" "asg2" {
  name                = "asg2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_network_interface_application_security_group_association" "asg2" {
  network_interface_id          = azurerm_network_interface.asg2_vm_nic.id
  application_security_group_id = azurerm_application_security_group.asg2.id
}