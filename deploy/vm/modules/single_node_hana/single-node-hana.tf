# Configure the Microsoft Azure Provider
provider "azurerm" {}

module "common_setup" {
  source            = "../common_setup"
  allow_ips         = "${var.allow_ips}"
  az_region         = "${var.az_region}"
  az_resource_group = "${var.az_resource_group}"
  existing_nsg_name = "${var.existing_nsg_name}"
  existing_nsg_rg   = "${var.existing_nsg_rg}"
  install_xsa       = "${var.install_xsa}"
  sap_instancenum   = "${var.sap_instancenum}"
  sap_sid           = "${var.sap_sid}"
  use_existing_nsg  = "${var.use_existing_nsg}"
}

module "create_hdb" {
  source = "../create_hdb_node"

  az_resource_group         = "${module.common_setup.resource_group_name}"
  az_region                 = "${var.az_region}"
  hdb_num                   = 0
  az_domain_name            = "${var.az_domain_name}"
  hana_subnet_id            = "${module.common_setup.vnet_subnets[0]}"
  nsg_id                    = "${module.common_setup.nsg_id}"
  private_ip_address        = "${var.private_ip_address_hdb}"
  public_ip_allocation_type = "${var.public_ip_allocation_type}"
  sap_sid                   = "${var.sap_sid}"
  sshkey_path_public        = "${var.sshkey_path_public}"
  storage_disk_sizes_gb     = "${var.storage_disk_sizes_gb}"
  vm_user                   = "${var.vm_user}"
  vm_size                   = "${var.vm_size}"
}

# Writes the configuration to a file, which will be used by the Ansible playbook for creating linux bastion host
resource "local_file" "write-config-to-json" {
  content  = "${data.template_file.config.rendered}"
  filename = "temp.json"
}

data "template_file" "config" {
  template = "${file("../common_files/config_template.tpl")}"

  vars {
    linux_bastion_name                 = "${local.linux_vm_name}"
    vnet_name                          = "${module.common_setup.vnet_name}"
    subnet_name                        = "${module.common_setup.subnet_names[0]}"
    linux_bastion                      = "${var.linux_bastion}"
    url_linux_hana_studio              = "${var.url_hana_studio_linux}"
    url_linux_sapcar                   = "${var.url_sap_sapcar_linux}"
    az_resource_group                  = "${module.common_setup.resource_group_name}"
    nsg_id                             = "${module.common_setup.nsg_id}"
    vm_user_linux_bastion              = "${var.vm_user}"
    private_ip_address_linux_bastion   = "${var.private_ip_address_linux_bastion}"
    vm_size_linux_bastion              = "${var.vm_size}"
    sshkey_path_public                 = "${var.sshkey_path_public}"
    sshkey_path_private                = "${var.sshkey_path_private}"
    windows_bastion                    = "${var.windows_bastion}"
    allow_ips                          = "${length(var.allow_ips) > 0 ? jsonencode(var.allow_ips): local.all_ips}"
    url_sapcar_windows                 = "${var.url_sapcar_windows}"
    url_hana_studio_windows            = "${var.url_hana_studio_windows}"
    bastion_username_windows           = "${var.bastion_username_windows}"
    pw_bastion_windows                 = "${var.pw_bastion_windows}"
    az_domain_name                     = "${var.az_domain_name}"
    private_ip_address_windows_bastion = "${var.private_ip_address_windows_bastion}"
    vm_name_win_bastion                = "${lower(var.sap_sid)}-win-bastion"
  }
}

module "configure_vm" {
  source                = "../playbook-execution"
  ansible_playbook_path = "${var.ansible_playbook_path}"
  az_resource_group     = "${module.common_setup.resource_group_name}"
  sshkey_path_private   = "${var.sshkey_path_private}"
  sap_instancenum       = "${var.sap_instancenum}"
  sap_sid               = "${var.sap_sid}"
  vm_user               = "${var.vm_user}"
  url_sap_sapcar        = "${var.url_sap_sapcar_linux}"
  url_sap_hdbserver     = "${var.url_sap_hdbserver}"
  pw_os_sapadm          = "${var.pw_os_sapadm}"
  pw_os_sidadm          = "${var.pw_os_sidadm}"
  pw_db_system          = "${var.pw_db_system}"
  useHana2              = "${var.useHana2}"
  vms_configured        = "${module.create_hdb.machine_hostname}"
  hana1_db_mode         = "${var.hana1_db_mode}"
  url_xsa_runtime       = "${var.url_xsa_runtime}"
  url_di_core           = "${var.url_di_core}"
  url_sapui5            = "${var.url_sapui5}"
  url_portal_services   = "${var.url_portal_services}"
  url_xs_services       = "${var.url_xs_services}"
  url_shine_xsa         = "${var.url_shine_xsa}"
  url_xsa_hrtt          = "${var.url_xsa_hrtt}"
  url_xsa_webide        = "${var.url_xsa_webide}"
  url_xsa_mta           = "${var.url_xsa_mta}"
  pwd_db_xsaadmin       = "${var.pwd_db_xsaadmin}"
  pwd_db_tenant         = "${var.pwd_db_tenant}"
  pwd_db_shine          = "${var.pwd_db_shine}"
  email_shine           = "${var.email_shine}"
  install_xsa           = "${var.install_xsa}"
  install_shine         = "${var.install_shine}"
  install_cockpit       = "${var.install_cockpit}"
  install_webide        = "${var.install_webide}"
  url_cockpit           = "${var.url_cockpit}"
}

# Destroy the linux bastion host
resource null_resource "destroy-vm" {
  provisioner "local-exec" {
    when = "destroy"

    command = <<EOT
               OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES \
               AZURE_RESOURCE_GROUPS="${var.az_resource_group}" \
               ANSIBLE_HOST_KEY_CHECKING="False" \
               ansible-playbook -u '${var.vm_user}' \
               --private-key '${var.sshkey_path_private}' \
               --extra-vars="{az_resource_group: \"${module.common_setup.resource_group_name}\", az_vm_name: \"${local.linux_vm_name}\"}" ../../ansible/delete_bastion_linux.yml
EOT
  }
}

# Destroy the Windows bastion host
resource null_resource "destroy-win-vm" {
  provisioner "local-exec" {
    when = "destroy"

    command = <<EOT
               OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES \
               AZURE_RESOURCE_GROUPS="${var.az_resource_group}" \
               ANSIBLE_HOST_KEY_CHECKING="False" \
               ansible-playbook -u '${var.vm_user}' \
               --extra-vars="{az_resource_group: \"${module.common_setup.resource_group_name}\", az_vm_name: \"${lower(var.sap_sid)}-win-bastion\"}" ../../ansible/delete_bastion_windows.yml
EOT
  }
}
