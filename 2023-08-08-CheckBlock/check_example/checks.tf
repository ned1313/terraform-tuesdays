locals {
  status_code = 200
}

check "website_working" {
  data "http" "web_page" {
    url = "http://${data.azurerm_public_ip.pip.ip_address}"
  }

  assert {
    condition     = data.http.web_page.status_code == local.status_code
    error_message = "${data.http.web_page.url} status is not ${local.status_code}"
  }
}

locals {
  allowed_ports = ["80", "443"]
}

check "allowed_ports_only" {

  data "azurerm_network_security_group" "nsg" {
    name                = azurerm_network_security_group.allow_web.name
    resource_group_name = azurerm_resource_group.example.name
  }

  assert {
    condition     = setunion([for rule in data.azurerm_network_security_group.nsg.security_rule : rule.destination_port_range if rule.direction == "Inbound" && rule.access == "Allow"], local.allowed_ports) == toset(local.allowed_ports)
    error_message = "${data.azurerm_network_security_group.nsg.name} includes port rules that are not in the list: ${join(",", local.allowed_ports)}."
  }
}

check "server_on" {
  data "azurerm_virtual_machine" "web" {
    name                = module.ubuntu_server.vm_name
    resource_group_name = azurerm_resource_group.example.name
  }

  assert {
    condition     = data.azurerm_virtual_machine.web.power_state == "running"
    error_message = "${data.azurerm_virtual_machine.web.name} is not running."
  }
}


data "azurerm_virtual_machine" "web2" {
  name                = module.ubuntu_server.vm_name
  resource_group_name = azurerm_resource_group.example.name
}
