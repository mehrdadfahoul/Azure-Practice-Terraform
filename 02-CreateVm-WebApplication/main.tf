provider "azurerm" {
    features {}
    subscription_id = "Enter Your subscription"
}
resource "azurerm_resource_group" "RG" {
    name = "RG"
    location = "East US"
}
resource "azurerm_virtual_network" "NW" {
  name = "NW"
  location = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  address_space = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "SB" {
    name = "SB"
    resource_group_name = azurerm_resource_group.RG.name
    virtual_network_name = azurerm_virtual_network.NW.name
    address_prefixes = ["10.0.0.0/24"]
}
resource "azurerm_network_security_group" "NSG" {
    name = "NetSecGr"
    location = azurerm_resource_group.RG.location
    resource_group_name = azurerm_resource_group.RG.name
    security_rule {
        name = "Allow-SSH"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name = "Allow-Web-Port"
        priority = 1002
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "80"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}
resource "azurerm_network_interface" "NI" {
    name = "NI"
    location = azurerm_resource_group.RG.location
    resource_group_name = azurerm_resource_group.RG.name
    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.SB.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.IPP.id
    } 
}
resource "azurerm_public_ip" "IPP" {
    name = "IPP"
    location = azurerm_resource_group.RG.location
    resource_group_name = azurerm_resource_group.RG.name
    allocation_method = "Static"
    sku =  "Standard"
}

resource "azurerm_linux_virtual_machine" "LinuxServer" {
    name = "webServer-linux"
    location = azurerm_resource_group.RG.location
    resource_group_name = azurerm_resource_group.RG.name
    size = "Standard_B1s"
    admin_username = "mehrdad"
    admin_password = "AAAaaa123..."
    network_interface_ids = [azurerm_network_interface.NI.id]

        admin_ssh_key {
      username = "mehrdad"
      public_key = file("~/.ssh/id_rsa.pub")
    }



    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer = "UbuntuServer"
      sku = "20.04-LTS"
      version = "latest"
    }
}
