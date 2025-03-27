provider "azurerm" {
    features {}
    subscription_id = "Enter your subscription"
}
resource "azurerm_resource_group" "vmresourcegroup" {
  name = "mehrdadresourcegroup"
  location = "East US"
}
resource "azurerm_virtual_network" "vmnetwork" {
    name = "mehrdadnetwork"
    location = azurerm_resource_group.vmresourcegroup.location
    resource_group_name = azurerm_resource_group.vmresourcegroup.name
    address_space = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "vmsubnet" {
    name = "mehrdadsubnet"
    resource_group_name = azurerm_resource_group.vmresourcegroup.name
    virtual_network_name = azurerm_virtual_network.vmnetwork.name
    address_prefixes = ["10.0.0.0/24"]
}
resource "azurerm_network_interface" "vminterface" {
    name = "mehrdadinterface"
    location = azurerm_resource_group.vmresourcegroup.location
    resource_group_name = azurerm_resource_group.vmresourcegroup.name
    ip_configuration {
      
      name = "internal"
      subnet_id = azurerm_subnet.vmsubnet.id
      private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "vmvirtual" {
    name = "mehrdadVM"
    resource_group_name = azurerm_resource_group.vmresourcegroup.name
    location = azurerm_resource_group.vmresourcegroup.location
    size = "Standard_B1s"
    admin_username = "mehrdaduser"
    admin_password = "AAAaaa123..."
    network_interface_ids = [azurerm_network_interface.vminterface.id]
    
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }
    source_image_reference {
      publisher = "MicrosoftWindowsServer"
      offer = "WindowsServer"
      sku = "2019-DataCenter"
      version = "latest"
    }
}