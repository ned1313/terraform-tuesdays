locals {
  # Load all of the data from json
  all_json_data = jsondecode(file("config_data.json"))

  # Load the first list of data directly
  list1_data = jsondecode(file("config_data.json")).List1

  # Load the first map indirectly
  map1_data = local.all_json_data.Map1
}