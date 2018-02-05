resource "azurerm_public_ip" "mgmtpip" {
  name                         = "${var.project}-${var.env}-mngm-pip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  public_ip_address_allocation = "dynamic"

  tags {
      environment = "${var.tag_enviroment}"
  }
}

resource "azurerm_network_interface" "mgmt-nic" {
  name                = "nic-${var.project}-${var.env}-mgmt"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  ip_configuration {
    name                                    = "ipconfig-mgmt-${var.project}-${var.env}"
    subnet_id                               = "${azurerm_subnet.subnet.*.id[0]}"
    private_ip_address_allocation           = "Dynamic"
    public_ip_address_id                    = "${azurerm_public_ip.mgmtpip.id}"
  }

  tags {
      environment = "${var.tag_enviroment}"
  }

}

resource "azurerm_virtual_machine" "mgmt-vm" {
  name                  = "mgmt-vm-${var.project}-${var.env}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.mgmt-nic.id}"]

  storage_image_reference {
    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
    version   = "${var.version}"
  }

  storage_os_disk {
    name              = "mgmt-osdisk-${var.project}-${var.env}"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
  }

  os_profile {
    computer_name  = "azure-mgmt-${var.project}-${var.env}-01"
    admin_username = "${var.os_user}"
    admin_password = "${var.os_pass}"
    custom_data    = <<-EOF
      #!/bin/bash
      wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add - >> /var/log/install.log
      echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list
      apt-get update >> /var/log/install.log
      apt-get install salt-minion -y >> /var/log/install.log
      echo "id: azure-mgmt-${var.project}-${var.env}-01" > /etc/salt/minion.d/minion.conf
      echo "master_port: 4506" >> /etc/salt/minion.d/minion.conf
      echo "publish_port: 4505" >> /etc/salt/minion.d/minion.conf
      echo "environment: dev" >> /etc/salt/minion.d/minion.conf
      echo "state_top_saltenv: dev" >> /etc/salt/minion.d/minion.conf
      echo "default_top: dev" >> /etc/salt/minion.d/minion.conf
      echo "test: False" >> /etc/salt/minion.d/minion.conf
      echo "master: saltmasterhost" >> /etc/salt/minion.d/minion.conf
      echo "master_type: str" >> /etc/salt/minion.d/minion.conf
      systemctl enable salt-minion >> /var/log/install.log
      systemctl restart salt-minion >> /var/log/install.log
      EOF
  }

  os_profile_linux_config {
     disable_password_authentication = false
    ssh_keys {
      path     = "/home/${var.os_user}/.ssh/authorized_keys"
      key_data = "ssh-rsa *** admin@company.sk"
          }
  }

  tags {
      environment = "${var.tag_enviroment}"
  }
}
