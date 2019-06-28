# Creates network interface
resource "azurerm_network_interface" "demo-nic" {
  name                      = "${var.az_vm}-nic"
  location                  = var.az_region
  resource_group_name       = var.az_resource_group
  network_security_group_id = var.az_nsg_id

  ip_configuration {
    name				= "${var.az_vm}-nic-configuration"
    subnet_id				= var.az_subnet_id
    private_ip_address_allocation	= "static"
    private_ip_address			= var.az_private_ip_address
    
  }
}

