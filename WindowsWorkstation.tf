data "azurerm_image" "search" {
  name_regex          = "${var.image_name}"
  resource_group_name = "${var.image_rg_name}"
  sort_descending = true
}

#create a public IP address for the virtual machine
resource "azurerm_public_ip" "workstation_pubip" {
  count                        = "${var.count}"
  name                         = "workstation${count.index}_pubip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method = "Dynamic"
  domain_name_label            = "workstation${count.index}-${lower(substr("${join("", split(":", timestamp()))}", 8, -1))}"

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

#create the network interface and put it on the proper vlan/subnet
resource "azurerm_network_interface" "workstation_ip" {
  count                        = "${var.count}"
  name                = "workstation${count.index}_ip"
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"

  ip_configuration {
    name                          = "workstation${count.index}_ipconf"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.workstation_pubip.*.id, count.index)}"
  }
  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

#create the actual VM
resource "azurerm_virtual_machine" "workstation" {
  count                 = "${var.count}"
  name                  = "workstation${count.index}"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.workstation_ip.*.id, count.index)}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }

  storage_os_disk {
    name              = "workstation${count.index}_osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "workstation${count.index}"
    admin_username = "${var.username}"
    admin_password = "${var.password}"
    custom_data    = "${file("./files/config.ps1")}"
  }

  tags {
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  os_profile_windows_config {
    provision_vm_agent = true
    winrm {
      protocol = "http"
    }
    # Auto-Login's required to configure WinRM
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.username}</Username></AutoLogon>"
    }

    # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = "${file("./files/FirstLogonCommands.xml")}"
    }
  }
}

output "workstation_public_ips" {
  value = ["${azurerm_public_ip.workstation_pubip.*.fqdn}"]
}