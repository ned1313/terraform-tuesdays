### Initialize and apply terraform
terraform init
terraform apply

terraform apply -var my_boo=false -var my_int=-1

### Now let's try conditional resource creation
### Uncomment the first resource and try it out
terraform init
terraform apply
terraform workspace new dev
terraform apply

### Uncomment the second resource and try it out
terraform workspace select default
terraform apply

terraform workspace select dev
terraform apply

### Let's try some stuff in Terraform Console
terraform console

!var.my_boo

var.my_boo && true

var.my_boo && false

var.my_boo || false

var.my_boo && var.my_int

var.my_boo && var.my_string

var.my_boo && var.my_string == ""

var.my_int * 100 > 1000