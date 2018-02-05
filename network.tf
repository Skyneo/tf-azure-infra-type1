resource "azurerm_virtual_network" "network" {
    # count               = "${length(var.net_name)}"
    # name                = "net-${var.project}-${var.env}-${lookup(var.net_name, count.index)}"
    name                = "net-${var.project}-${var.env}"
    address_space       = ["${var.cidr}"]
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

    # subnet {
    #     name           = "subnet-${var.project}-${var.env}-${lookup(var.net_name, count.index)}"
    #     address_prefix = "${cidrsubnet(var.cidr,var.newbits,var.netnum+count.index)}"
    #   }

    tags {
        environment = "${var.tag_enviroment}"
    }
}


resource "azurerm_subnet" "subnet" {
  count                = "${length(var.net_name)}"
  name                 = "subnet-${var.project}-${var.env}-${lookup(var.net_name, count.index)}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_id = "${azurerm_network_security_group.securitygroup.id}"
  address_prefix       = "${cidrsubnet(var.cidr,var.newbits,var.netnum+count.index)}"
}
