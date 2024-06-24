# We are going to load some data into locals values and then
# manipulate it with the terraform console

terraform init
terraform console

# Console commands
# Show all the json data
local.all_json_data

# Show the json data from List1
local.list1_data

# Show the json data from Map1
local.map1_data

#Refer to a list element
local.list1_data[0]

# Refer to a map element
local.map1_data.MapKey1

# How about a for loop on a list?
[ for i in local.all_json_data.List1 : upper(i) ]

# What about transposing keys and values?
{ for key, val in local.map1_data : val => key }

[ for k, v in local.map1_data : "${v}-${k}" ]

# How about we get a list for only Tacos?
[ for i in local.all_json_data.List3 : i if i.Food == "Taco"]
