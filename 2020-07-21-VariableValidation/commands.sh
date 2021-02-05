terraform13 init

#There will be errors
terraform13 apply 

# Comment out the always wrong

#Try with bad values

terraform13 apply -var no_caps=ALL_CAPS

terraform13 apply -var ip_address=10.1.1.

# Uncomment module
terraform13 apply -var no_caps=morethanthree