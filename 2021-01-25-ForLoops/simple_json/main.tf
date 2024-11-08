locals {
  # Load all of the data from json
  all_json_data = jsondecode(file("config_data.json"))

  # Load the first list of data directly
  list1_data = jsondecode(file("config_data.json")).List1

  # Load the first map indirectly
  map1_data = local.all_json_data.Map1
}


 

#map of maps for creating subnets
variable "subnet_map" {
   type = map
   default = {
      subnet-1 = {
         az = "us-west-1a"
         cidr = "10.0.198.0/24"
      }
      subnet-2 = {
         az = "us-east-1a"
         cidr = "10.0.199.0/24"
      }
      subnet-3 = {
         az = "us-east-2a"
         cidr = "10.0.200.0/24"
      }
   }
}
