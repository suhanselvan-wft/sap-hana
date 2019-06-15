# Subscription ID of the Azure Subscription to deploy
subscription_id="76e2a854-f354-47f5-a80c-ab05c6f54cf4"

# Client ID of the Azure Service Principal used to deploy
client_id="67c10762-31df-4a19-a732-9f1eb19a9c1e"

# Client secret of the Azure Service Principal
client_secret="_L7l5bxm.0d6GRy+rC+=8lZ028HiB]5X"

# Tenant ID of the Azure Subscription to deploy
tenant_id="64d2bae0-5ea5-4785-a741-b8a0071f0a11"

# Azure region to deploy resource in; please choose the same region as your storage from step 3 (example: "westus2")
az_region = "westus2"

# Name of existing resource group to deploy (example: "demo1")
az_resource_group = "demo1"

# Name of the availability set to deploy
az_availability_set = ""

# Name of the availability zone to deploy
az_availability_zone = "2" 

# Unique domain name for easy VM access (example: "hana-on-azure1")
az_domain_name = "hana-on-azure1"

# Size of the VM to be deployed (example: "Standard_E8s_v3")
# For HANA platform edition, a minimum of 32 GB of RAM is recommended
vm_size = "Standard_D8s_v3"

# Path to the public SSH key to be used for authentication (e.g. "~/.ssh/id_rsa.pub")
sshkey_path_public = "~/.ssh/id_rsa.pub"

# Path to the corresponding private SSH key (e.g. "~/.ssh/id_rsa")
sshkey_path_private = "~/.ssh/id_rsa"

# OS user with sudo privileges to be deployed on VM (e.g. "demo")
vm_user = "demo"

# SAP system ID (SID) to be used for HANA installation (example: "HN1")
sap_sid = "HN1"

# SAP instance number to be used for HANA installation (example: "01")
sap_instancenum = "01"

# URL to download SAPCAR binary from (see step 6)
url_sap_sapcar_linux = "https://wftsapstorageaccount.blob.core.windows.net/sapbits/SAPCAR_1211-80000935.EXE"

# URL to download HANA DB server package from (see step 6)
url_sap_hdbserver = "https://wftsapstorageaccount.blob.core.windows.net/sapbits/IMDB_SERVER100_122_25-10009569.SAR"

# Password for the OS sapadm user
pw_os_sapadm = "C@rn1v@l201701!"

# Password for the OS <sid>adm user
pw_os_sidadm = "C@rn1v@l201701!"

# Password for the DB SYSTEM user
# (In MDC installations, this will be for SYSTEMDB tenant only)
pw_db_system = "C@rn1v@l201701!"

# Password for the DB XSA_ADMIN user
pwd_db_xsaadmin = "C@rn1v@l201701!"

# Password for the DB SYSTEM user for the tenant DB (MDC installations only)
pwd_db_tenant = "C@rn1v@l201701!"

# Password for the DB SHINE_USER user (SHINE demo content only)
pwd_db_shine = "C@rn1v@l201701!"

# e-mail address used for the DB SHINE_USER user (SHINE demo content only)
email_shine = "suhans@wftus.com"

# Set this flag to true when installing HANA 2.0 (or false for HANA 1.0)
useHana2 = false

# Set this flag to true when installing the XSA application server
install_xsa = false

# Set this flag to true when installing SHINE demo content (requires XSA)
install_shine = false

# Set this flag to true when installing Cockpit (requires XSA)
install_cockpit = false

# Set this flag to true when installing WebIDE (requires XSA)
install_webide = false

# Set this to be a list of the ip addresses that should be allowed by the NSG.
allow_ips = ["0.0.0.0/0"]
