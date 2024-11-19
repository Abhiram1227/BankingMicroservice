provider "azurerm" {
  features {}
  subscription_id = "0f1313cb-b826-4712-a9d3-ccd096a124f2"
}
 
# Resource Group
resource "azurerm_resource_group" "rg_new" {
  name     = "rg-New"
  location = "Canada Central"
}
 
# Virtual Network
resource "azurerm_virtual_network" "vnet_new" {
  name                = "vnet-New"
  address_space       = ["192.168.0.0/19"]
  location            = azurerm_resource_group.rg_new.location
  resource_group_name = azurerm_resource_group.rg_new.name
}
 
# Subnet
resource "azurerm_subnet" "subnet_new" {
  name                 = "subnet-New"
  resource_group_name  = azurerm_resource_group.rg_new.name
  virtual_network_name = azurerm_virtual_network.vnet_new.name
  address_prefixes     = ["192.168.0.0/24"]
}
 
# Network Security Group
resource "azurerm_network_security_group" "nsg_new" {
  name                = "nsg-New"
  location            = azurerm_resource_group.rg_new.location
  resource_group_name = azurerm_resource_group.rg_new.name
}
 
# Public IP Address
resource "azurerm_public_ip" "vm_public_ip_new" {
  name                = "vm-public-ip-new"
  location            = azurerm_resource_group.rg_new.location
  resource_group_name = azurerm_resource_group.rg_new.name
  allocation_method   = "Static"
  sku                  = "Standard"
  domain_name_label   = "myvm-public-ip-new"
}
 
# Network Interface for Linux VM
resource "azurerm_network_interface" "nic_linux_new" {
  name                = "nic-linux-vm-new"
  location            = azurerm_resource_group.rg_new.location
  resource_group_name = azurerm_resource_group.rg_new.name
 
  ip_configuration {
    name                          = "ipconfig-linux-new"
    subnet_id                     = azurerm_subnet.subnet_new.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip_new.id  # Associate Public IP
  }
}
 
# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "linux_vm_new" {
  name                            = "linux-vm-new"
  resource_group_name             = azurerm_resource_group.rg_new.name
  location                        = azurerm_resource_group.rg_new.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser_new"
  admin_password                  = "Password@123"  # Please consider using a more secure way to handle this, e.g., Key Vault, or environment variables
  disable_password_authentication = false
 
  network_interface_ids = [azurerm_network_interface.nic_linux_new.id]
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 
  source_image_reference {
    publisher = "solvedevops1643693563360"
    offer     = "rocky-linux-9"
    sku       = "plan001"
    version   = "latest"
  }
 
  plan {
    name      = "plan001"
    publisher = "solvedevops1643693563360"
    product   = "rocky-linux-9"
  }
 
  custom_data = base64encode(file("user-data.sh"))  # Base64 encode the user-data script for cloud-init
}
 
# Output Public IP Address
output "vm_public_ip_new" {
  value = azurerm_public_ip.vm_public_ip_new.ip_address
}
