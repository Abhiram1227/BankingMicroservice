provider "azurerm" {
  features {}
  subscription_id = "0f1313cb-b826-4712-a9d3-ccd096a124f2"
}
 
# Resource Group
resource "azurerm_resource_group" "rg1" {
  name     = "rg1-NewDeployment"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-NewDeployment"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-NewDeployment"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-NewDeployment"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP Address
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip-NewDeployment"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
  sku                  = "Standard"
  domain_name_label   = "newdeployment-public-ip"
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
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                            = "linux-vm-NewDeployment"
  resource_group_name             = azurerm_resource_group.rg1.name
  location                        = azurerm_resource_group.rg1.location
  size                            = "Standard_B2ms"
  admin_username                  = "adminuser"
  admin_password                  = "SecurePassword@123"  # Replace with secure credentials
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic_linux.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(file("user-data.sh"))
}

# Load Balancer
resource "azurerm_lb" "lb" {
  name                            = "lb-NewDeployment"
  location                        = azurerm_resource_group.rg1.location
  resource_group_name             = azurerm_resource_group.rg1.name
  sku                             = "Standard"
}

# Load Balancer Frontend IP Configuration
resource "azurerm_lb_frontend_ip_configuration" "frontend" {
  name                                = "frontend-config-NewDeployment"
  resource_group_name                 = azurerm_resource_group.rg1.name
  loadbalancer_id                     = azurerm_lb.lb.id
  subnet_id                           = azurerm_subnet.subnet.id
  public_ip_address_id               = azurerm_public_ip.vm_public_ip.id
}

# Virtual Machine Scale Set (VMSS)
resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                             = "vmss-NewDeployment"
  location                         = azurerm_resource_group.rg1.location
  resource_group_name              = azurerm_resource_group.rg1.name
  sku                              = "Standard_D2_v3"
  instances                        = 3
  upgrade_policy {
    mode = "Automatic"
  }

  network_profile {
    name    = "network-profile"
    primary = true

    network_interface {
      name                                   = "vmss-nic"
      primary                                = true
      enable_ip_forwarding                  = true
      ip_configuration {
        name                                 = "ipconfig"
        subnet_id                            = azurerm_subnet.subnet.id
        private_ip_address_allocation        = "Dynamic"
        public_ip_address_id                 = azurerm_public_ip.vm_public_ip.id
      }
    }
  }

  os_profile {
    computer_name_prefix = "vmss-instance"
    admin_username       = "adminuser"
    admin_password       = "SecurePassword@123"  # Replace with secure credentials
  }

  storage_profile {
    os_disk {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    image_reference {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "20.04-LTS"
      version   = "latest"
    }
  }
}

# Output Public IP Address
output "vm_public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}

output "load_balancer_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
