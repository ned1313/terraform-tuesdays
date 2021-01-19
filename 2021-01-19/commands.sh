# We're going to set up two different mirror caches
# The first will be the expanded path for the plugin 
# The second will just be the zip file
# We can get the plugin from the public repository by
# using the provider registry protocol.

# We can get the full listing of provider versions by using curl
# The format is https://hostname/v1/providers/<namespace>/<type>/versions
# The azurerm provider is an official HashiCorp provider
# So we can get it using the address registry.terraform.io

curl 'https://registry.terraform.io/v1/providers/hashicorp/azurerm/versions'

# That's too much info for us. Let's just get the version numbers using jq to 
# parse the response

resp=$(curl 'https://registry.terraform.io/v1/providers/hashicorp/azurerm/versions')
echo $resp | jq .versions[].version | sort -r

# In our case, we know we want version 2.41.0, but we could use this to find latest
# Or the latest of a specific major/minor version

# To get the specific provider plugin, we need to select an OS and architecture
# You can see those by parsing the json response for the version we want

echo $resp | jq '.versions[] | select(.version=="2.41.0")'

# The output shows us all the architectures we might want to use
# Let's pick linux for an OS and amd64 for the architecture
# Using those values, we can construct a new request for the plugin

resp=$(curl 'https://registry.terraform.io/v1/providers/hashicorp/azurerm/2.41.0/download/linux/amd64')
echo $resp | jq .download_url -r

# Now we have address where we can get our zip file. You could do this programattically for each provider
# You intend to use and each OS and arch you intend to use it on

# Hey guess, what? You don't need to do any of this, b/c Terraform now has a command
# To do it for you `terraform providers mirror`
# Let's use that instead shall we?

mkdir ~/terraform-file-mirror
terraform providers mirror ~/terraform-file-mirror/

tree ~/terraform-file-mirror

# What's cool is you can setup a local file mirror or a network mirror
# Since the necessary json is included

# Let's configure a local mirror using our CLI config
# Now I don't want to mess with your local config file if you already have one
# So let's use an env variable to temporarily set the CLI config to a different
# directory

export TF_CLI_CONFIG_FILE="$HOME/.terraformrctemp"
cat <<EOF > $TF_CLI_CONFIG_FILE
provider_installation {
  filesystem_mirror {
    path    = "$HOME/terraform-file-mirror/"
    include = ["hashicorp/azurerm"]
  }
  direct {
    exclude = ["hashicorp/azurerm"]
  }
}
EOF

# Now let's try to use our filesystem mirror
export TF_LOG=DEBUG

terraform init

# Bonus points... let's try and set up a network mirror
# Basically, we need to get a web server running and mount
# the directoy we created for the file system mirror as the 
# root of the server. I'm going to use docker to do this

docker run --name network_mirror -d -p 8080:80 -v $HOME/terraform-file-mirror:/usr/share/nginx/html nginx

# Let's recreate our CLI config file
rm $TF_CLI_CONFIG_FILE

cat <<EOF > $TF_CLI_CONFIG_FILE
provider_installation {
  network_mirror {
    url    = "http://localhost:8080"
    include = ["hashicorp/azurerm"]
  }
  direct {
    exclude = ["hashicorp/azurerm"]
  }
}
EOF