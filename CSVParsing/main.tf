locals {
  csv_data = csvdecode(file("values.csv"))
  
  data_map = {for k in local.csv_data : k.Group => k}
  
}

