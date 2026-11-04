resource "azurerm_resource_group" "rg1" {
  name     = "rg1"
  location = "east us"
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  
}

resource "azurerm_public_ip" "pip" {
  count = 3
  name = "vm-pip-${count.index}"
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method = "Static"
  location = azurerm_resource_group.rg1.location
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  count = 3
  name                = "vm-nic-${count.index}"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip[count.index].id
    }
}
resource "azurerm_windows_virtual_machine" "vm" {
  count               = 3
  name                = "windows-vm-${count.index}"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = "Standard_E2ads_v7"
  admin_username      = "adminuser"
  network_interface_ids = [ azurerm_network_interface.nic[count.index].id,]
  admin_password      = "P@$$w0rd1234!"
  
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name = "osdisk-${count.index}"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
}

