resource "azurerm_public_ip" "asg1_vm_public_ip" {
  name                = "asg1-vm-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "asg1_vm_nic" {
  name                = "asg1-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "asg1-vm-nic-ip"
    subnet_id                     = azurerm_subnet.asg_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.asg1_vm_public_ip.id
  }
}

resource "azurerm_virtual_machine" "asg1_vm" {
  name                             = "asg1-vm"
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  network_interface_ids            = [azurerm_network_interface.asg1_vm_nic.id]
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
    name              = "asg1-vm-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "asg1-vm"
    admin_username = "asg1-admin"
    admin_password = "S3cureP@ssw0rd"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_application_security_group" "asg1" {
  name                = "asg1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_network_interface_application_security_group_association" "asg1" {
  network_interface_id          = azurerm_network_interface.asg1_vm_nic.id
  application_security_group_id = azurerm_application_security_group.asg1.id
}