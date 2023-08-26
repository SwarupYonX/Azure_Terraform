# Configure Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.59.0"
    } 
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}

  skip_provider_registration = "true"
  
  # Connection to Azure
  subscription_id = var.1626ae11-72db-45da-9c09-30697a33c917
  client_id = var.78ef6be1-86d0-4b6d-bb33-6613dcbbb005
  client_secret = var.1626ae11-72db-45da-9c09-30697a33c917
  tenant_id = var.b57210f0-0cf6-4a7e-aca6-76b85ccbb728
}

variable "prefix" {
  default = "terraform"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-ResourceGroup"
  location = "Central India"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-VNet"
  address_space       = ["10.0.0.0/16"] # address space refers to the entire range of IP addresses available for allocation within a specific network.
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"] # Address prefixes are subsets of the overall address space. They represent smaller, contiguous ranges of IP addresses carved out of the larger address space.
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "tfconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_D1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "tfadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

