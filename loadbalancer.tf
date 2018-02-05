resource "azurerm_availability_set" "avset" {
  name                         = "${var.project}-${var.env}-avset"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}


resource "azurerm_public_ip" "lbpip" {
  name                         = "${var.project}-${var.env}-app-pip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  public_ip_address_allocation = "dynamic"

  tags {
      environment = "${var.tag_enviroment}"
  }
}

resource "azurerm_lb" "lb" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  name                = "${var.project}-${var.env}-app-lb"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "${var.project}-${var.env}-app-LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }

  tags {
      environment = "${var.tag_enviroment}"
  }

}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "${var.project}-${var.env}-app-BackendPool"

}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "${var.project}-${var.env}-app-LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.project}-${var.env}-app-LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "${var.project}-${var.env}-app-tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}
