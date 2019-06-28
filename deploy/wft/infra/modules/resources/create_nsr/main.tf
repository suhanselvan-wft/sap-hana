resource "azurerm_network_security_rule" "demo-nsr" {
  depends_on		      = [var.demo_nsg_id]
  name                        = var.az_nsr
  priority                    = var.nsr_priority
  direction                   = var.nsr_direction
  access                      = var.nsr_access
  protocol                    = var.nsr_protocol
  source_port_range           = var.nsr_source_port_range
  destination_port_range      = var.nsr_destination_port_range
  source_address_prefix       = var.nsr_source_address_prefix
  destination_address_prefix  = var.nsr_destination_address_prefix
  resource_group_name         = var.az_resource_group
  network_security_group_name = var.az_nsg
}
