terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.86.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}

resource "azurerm_resource_group" "glasto_RG" {
  for_each = var.vm-locations
  name = "glasto_RG_${each.key}"
  location = each.value
}

resource "azurerm_virtual_network" "glasto_VNET" {
  name                = "glasto_VNET"
  address_space       = ["10.0.0.0/16"]
  for_each = var.vm-locations
  location            = azurerm_resource_group.glasto_RG[each.key].location
  resource_group_name = azurerm_resource_group.glasto_RG[each.key].name
}

resource "azurerm_subnet" "glasto_SNET" {
  name                 = "glasto_SNET"
  for_each = var.vm-locations
  resource_group_name  = azurerm_resource_group.glasto_RG[each.key].name
  virtual_network_name = azurerm_virtual_network.glasto_VNET[each.key].name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "glasto_NI" {
  name                = "glasto_NI"
  for_each = var.vm-locations
  location            = azurerm_resource_group.glasto_RG[each.key].location
  resource_group_name = azurerm_resource_group.glasto_RG[each.key].name
  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.glasto_SNET[each.key].id
    public_ip_address_id          = azurerm_public_ip.vm_public_IP[each.key].id
  }
}

resource "azurerm_public_ip" "vm_public_IP" {
  name                = "vm_public_IP"
  for_each = var.vm-locations
  resource_group_name = azurerm_resource_group.glasto_RG[each.key].name
  location            = azurerm_resource_group.glasto_RG[each.key].location
  allocation_method   = "Dynamic"

}

resource "azurerm_windows_virtual_machine" "glasto_vm" {
  for_each = var.vm-locations
  name                = "${each.key}"
  resource_group_name = azurerm_resource_group.glasto_RG[each.key].name
  location            = azurerm_resource_group.glasto_RG[each.key].location
  size                = "Standard_D2s_v3"
  admin_username = var.username
  admin_password = var.password
  network_interface_ids = [
    azurerm_network_interface.glasto_NI[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    # maybe update SKU?
    sku     = "win10-22h2-pro-g2"
    version = "latest"
  }
}

resource "azurerm_network_security_group" "glasto_SG" {
  name                = "glasto_SG"
  for_each = var.vm-locations
  location            = azurerm_resource_group.glasto_RG[each.key].location
  resource_group_name = azurerm_resource_group.glasto_RG[each.key].name
}

resource "azurerm_network_security_rule" "allow_RDP" {
  name                        = "allow_RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  for_each = var.vm-locations
  resource_group_name         = azurerm_resource_group.glasto_RG[each.key].name
  network_security_group_name = azurerm_network_security_group.glasto_SG[each.key].name
}

output "vm_ips" {
  value = {
    for key, public_ip in azurerm_public_ip.vm_public_IP : key => public_ip.ip_address
  }
}
