# We are doing to set the plugin cache directory with an environment variable. The director must already
# exist

# PowerShell
mkdir "$HOME/tf_cache"
$env:TF_PLUGIN_CACHE_DIR = "$HOME/tf_cache"

# bash
mkdir $HOME/tf_cache
export TF_PLUGIN_CACHE_DIR="$HOME/tf_cache"

# Init terraform and check out the cache dir
cd cache_setup
terraform init

# PowerShell
tree $env:TF_PLUGIN_CACHE_DIR

# bash
tree $TF_PLUGIN_CACHE_DIR

# Now try it with a different config
cd ../use_cache
terraform init

# Check out the .terraform directory

tree .terraform