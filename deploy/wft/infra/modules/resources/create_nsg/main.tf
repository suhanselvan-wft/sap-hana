resource "azurerm_network_security_group" "demo-nsg" {
  depends_on	      = [var.demo_rg_id]
  name                = var.az_nsg
  location            = var.az_region
  resource_group_name = var.az_resource_group
}
