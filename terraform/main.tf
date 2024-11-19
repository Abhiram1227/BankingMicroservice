provider "azurerm" {
  features {}
  subscription_id = "0f1313cb-b826-4712-a9d3-ccd096a124f2"
}
 
# Resource Group
resource "azurerm_resource_group" "rg1" {
  name     = "rg1-NewDeployment"
  location = "East US"  # Changed to East US for variety
}
 
# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-NewDeployment"
  address_space       = ["10.0.0.0/16"]  # Larger address space for flexibility
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}
 
# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-NewDeployment"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]  # Adjusted subnet for the new network
}
 
# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-NewDeployment"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}
 
# Public IP Address
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip-NewDeployment"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
  sku                  = "Standard"  # Using Standard SKU for better scalability
  domain_name_label   = "newdeployment-public-ip"  # Updated DNS name for the public IP
}
 
# Network Interface for Linux VM
resource "azurerm_network_interface" "nic_linux" {
  name                = "nic-linux-vm-NewDeployment"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
 
  ip_configuration {
    name                          = "ipconfig-linux"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id  # Associate Public IP
  }
}
 
# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                            = "linux-vm-NewDeployment"
  resource_group_name             = azurerm_resource_group.rg1.name
  location                        = azurerm_resource_group.rg1.location
  size                            = "Standard_B2ms"  # Updated to a more cost-effective size for testing/development
  admin_username                  = "adminuser"
  admin_password                  = "NewSecurePassword@123"  # Replace with secure credentials
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic_linux.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"  # Updated to a more commonly used version of Ubuntu
    version   = "latest"
  }

  custom_data = base64encode(file("user-data.sh"))
}

# Output Public IP Address
output "vm_public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
