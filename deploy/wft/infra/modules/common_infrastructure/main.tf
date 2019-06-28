# Creates the resource group
resource "azurerm_resource_group" "demo-rg"{
  name		= var.az_resource_group
  location	= var.az_region
}

# Creates the hub vnet
resource "azurerm_virtual_network" "demo-hub-vnet" {
  depends_on	        = [azurerm_resource_group.demo-rg]
  name			= var.az_hub_vnet
  location		= var.az_region
  resource_group_name	= var.az_resource_group
  address_space		= [var.az_hub_address_space]
}

# Creates the hub subnet
resource "azurerm_subnet" "demo-hub-subnet" {
  depends_on	       = [azurerm_virtual_network.demo-hub-vnet]
  name                 = var.az_hub_subnet
  resource_group_name  = var.az_resource_group
  virtual_network_name = var.az_hub_vnet
  address_prefix       = var.az_hub_subnet_prefix
}

# Creates the spoke vnet
resource "azurerm_virtual_network" "demo-spoke-vnet" {
  depends_on	        = [azurerm_resource_group.demo-rg]
  name			= var.az_spoke_vnet
  location		= var.az_region
  resource_group_name	= var.az_resource_group
  address_space		= [var.az_spoke_address_space]
}

# Creates the spoke db subnet
resource "azurerm_subnet" "demo-spoke-subnet" {
  depends_on	       = [azurerm_virtual_network.demo-spoke-vnet]
  name                 = var.az_spoke_db_subnet
  resource_group_name  = var.az_resource_group
  virtual_network_name = var.az_spoke_vnet
  address_prefix       = var.az_spoke_db_subnet_prefix
}

# Creates spoke db subnet nsg
module "create_spoke_db_subnet_nsg" {
  source		 = "../resources/create_nsg"
  az_nsg		 = "spoke-db-subnet-nsg"
  az_region              = var.az_region
  az_resource_group      = var.az_resource_group
  demo_rg_id	         = azurerm_resource_group.demo-rg.id
}

# Peers hub vnet to spoke vnet
resource "azurerm_virtual_network_peering" "demo-peer-hub-spoke" {
  depends_on		    = [azurerm_virtual_network.demo-hub-vnet, azurerm_virtual_network.demo-spoke-vnet]
  name                      = "hub-to-spoke-peering"
  resource_group_name       = var.az_resource_group
  virtual_network_name      = var.az_hub_vnet
  remote_virtual_network_id = azurerm_virtual_network.demo-spoke-vnet.id
}

# peers spoke vnet to hub vnet
resource "azurerm_virtual_network_peering" "demo-peer-spoke-hub" {
  depends_on		    = [azurerm_virtual_network.demo-hub-vnet, azurerm_virtual_network.demo-spoke-vnet] 
  name                      = "spoke-to-hub-peering"
  resource_group_name       = var.az_resource_group
  virtual_network_name      = var.az_spoke_vnet
  remote_virtual_network_id = azurerm_virtual_network.demo-hub-vnet.id
}

# Generate random text for a unique boot diagnostics storage account name.
resource "random_id" "randomId" {
  depends_on	        = [azurerm_resource_group.demo-rg]
  keepers = {
    # Generate a new id only when a new resource group is defined.
    resource_group = var.az_resource_group
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "bootdiag-storageaccount" {
  depends_on	        = [azurerm_resource_group.demo-rg]
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = var.az_resource_group
  location                 = var.az_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Creates jumpbox nsg
module "create_jumpbox_nsg" {
  source		 = "../resources/create_nsg"
  az_nsg		 = "jumpbox-nsg"
  az_region              = var.az_region
  az_resource_group      = var.az_resource_group
  demo_rg_id	         = azurerm_resource_group.demo-rg.id
}

# Creates jumpbox rdp network security rule
module "create_jumpbox_nsr1" {
  source				= "../resources/create_nsr"
  az_nsr				= "rdp"
  az_resource_group			= var.az_resource_group
  az_nsg				= module.create_jumpbox_nsg.demo_nsg_name
  nsr_priority				= 101
  nsr_direction				= "Inbound"
  nsr_access				= "allow"
  nsr_protocol				= "Tcp"
  nsr_source_port_range			= "*"
  nsr_destination_port_range		= 3389
  nsr_source_address_prefix		= "*"
  nsr_destination_address_prefix	= "*"
  demo_nsg_id				= module.create_jumpbox_nsg.demo_nsg_id
}

# Creates jumpbox ssh network security rule
module "create_jumpbox_nsr2" {
  source				= "../resources/create_nsr"
  az_nsr				= "ssh"
  az_resource_group			= var.az_resource_group
  az_nsg				= module.create_jumpbox_nsg.demo_nsg_name
  nsr_priority				= 102
  nsr_direction				= "Inbound"
  nsr_access				= "allow"
  nsr_protocol				= "Tcp"
  nsr_source_port_range			= "*"
  nsr_destination_port_range		= 22
  nsr_source_address_prefix		= "*"
  nsr_destination_address_prefix	= "*"
  demo_nsg_id				= module.create_jumpbox_nsg.demo_nsg_id
}

# Creates the jumpbox nic
module "create_jumpbox_nic" {
  source		= "../resources/create_nic"
  az_region		= var.az_region
  az_resource_group	= var.az_resource_group
  az_vm			= var.az_vm
  az_nsg_id		= module.create_jumpbox_nsg.demo_nsg_id
  az_subnet_id		= azurerm_subnet.demo-hub-subnet.id
  az_private_ip_address	= var.az_jumpbox_private_ip_address
}

# Creates jumpbox vm
module "create_jumpbox_vm" {
  source 		= "../resources/create_disks_and_vm"
  az_vm			= var.az_vm
  az_location		= var.az_region
  az_resource_group	= var.az_resource_group
  az_vm_size		= "Standard_D4s_v3"
  az_nic_id		= module.create_jumpbox_nic.demo_nic_id 					
  az_os			= var.az_jumpbox_os
}
  





