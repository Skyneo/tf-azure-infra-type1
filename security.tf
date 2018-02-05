resource "azurerm_network_security_group" "securitygroup" {
    name                = "sg-${var.project}-${var.env}-ssh"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "${var.tag_enviroment}"
    }
}


# resource "azurerm_network_security_group" "securitygroup" {
#     count               = "${length(var.sec_name)}"
#     name                = "sg-${var.project}-${var.env}-${lookup(var.net_name, count.index)}"
#     location            = "${var.location}"
#     resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
#
#     security_rule {
#         name                       = "SSH"
#         priority                   = 1001
#         direction                  = "Inbound"
#         access                     = "Allow"
#         protocol                   = "Tcp"
#         source_port_range          = "*"
#         destination_port_range     = "22"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#     }
#
#     tags {
#         environment = "${var.tag_enviroment}"
#     }
# }
