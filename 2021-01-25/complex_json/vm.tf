locals {
  # Load all of the data from json
  vm_json_data = jsondecode(file("config_data.json")).VirtualMachines
}