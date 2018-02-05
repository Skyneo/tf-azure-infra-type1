resource "azurerm_network_interface" "app-nic" {
  name                = "nic-${var.project}-${var.env}-app-${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  count               = "${var.app_vm_n}"

  ip_configuration {
    name                                    = "ipconfig-app-${var.project}-${var.env}-${count.index}"
    subnet_id                               = "${azurerm_subnet.subnet.*.id[1]}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
  }

  tags {
      environment = "${var.tag_enviroment}"
  }

}

resource "azurerm_virtual_machine" "app-vm" {
  name                  = "app-vm-${var.project}-${var.env}-${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  availability_set_id   = "${azurerm_availability_set.avset.id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${element(azurerm_network_interface.app-nic.*.id, count.index)}"]
  count                 = "${var.app_vm_n}"

  storage_image_reference {
    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
    version   = "${var.version}"
  }

  storage_os_disk {
    name              = "app-osdisk-${var.project}-${var.env}-${count.index}"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
  }

  os_profile {
    computer_name  = "azure-app-${var.project}-${var.env}-${format("%02d", count.index+1)}"
    admin_username = "${var.os_user}"
    admin_password = "${var.os_pass}"
    custom_data    = <<-EOF
      #!/bin/bash
      wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add - >> /var/log/install.log
      echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list
      apt-get update >> /var/log/install.log
      apt-get install salt-minion -y >> /var/log/install.log
      echo "id: azure-app-${var.project}-${var.env}-${format("%02d", count.index+1)}" > /etc/salt/minion.d/minion.conf
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

# resource "azurerm_virtual_machine_extension" "app-vm-docker" {
#   name                       = "docker-${var.project}-${var.env}-app-${count.index}"
#   location                   = "${var.location}"
#   resource_group_name        = "${azurerm_resource_group.resourcegroup.name}"
#   virtual_machine_name       = "${element(azurerm_virtual_machine.app-vm.*.name, count.index)}"
#   publisher                  = "Microsoft.Azure.Extensions"
#   type                       = "DockerExtension"
#   type_handler_version       = "1.0"
#   auto_upgrade_minor_version = true
#   count                      = "${var.app_vm_n}"
# }
