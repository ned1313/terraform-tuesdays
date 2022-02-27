# Get the file with jalapenos in it from the count loop
[ for item in local_file.count_loop : item if item.content == "jalapenos" ]

# Get the file with jalapenos in it from the for_each loop
local_file.for_each_loop["jalapenos"]