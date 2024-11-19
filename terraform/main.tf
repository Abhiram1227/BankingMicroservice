provider "azurerm" {
  features {}
  subscription_id = "0f1313cb-b826-4712-a9d3-ccd096a124f2"
}
 
# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-S2"
  location = "Canada Central"
}
 
# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-S2"
  address_space       = ["192.168.0.0/19"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
 
# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-S2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.0.0/24"]
}
 
# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-S2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
 
# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip-linux-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"  # You can use "Static" for a fixed IP
  sku                 = "Basic"    # Use "Standard" for better features and availability
 
  tags = {
    environment = "dev"
  }
}
 
# Network Interface for Linux VM
resource "azurerm_network_interface" "nic_linux" {
  name                = "nic-linux-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
 
  # Network interface configuration
  ip_configuration {
    name                          = "ipconfig-linux"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id  # Associate public IP
  }
}
 
# User Data Script (Base64 Encoded)
data "template_file" "user_data_script" {
  template = <<-EOT
    #!/bin/bash
    sudo dnf -y update
 
    # Install Docker
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo dnf install -y docker-compose-plugin
    docker compose version
 
    # Install Java 11 (OpenJDK)
    sudo dnf install -y java-11-openjdk-devel
    java -version
 
    # Install Maven
    sudo dnf install -y maven
    mvn -version
  EOT
}
 
# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                            = "linux-vm"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser"
  admin_password                  = "Password@123"  # Replace with secure credentials
  disable_password_authentication = false
 
  # Network interface for the VM
  network_interface_ids = [azurerm_network_interface.nic_linux.id]
 
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
 
  # User Data (Base64 Encoded)
  custom_data = base64encode(data.template_file.user_data_script.rendered)
 
  # Define SSH public key for authentication
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Provide your SSH public key file path here
  }
}
