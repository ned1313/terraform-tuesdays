# Login and select subscription
az Login
az account set -s SUB_NAME

id=$(((RANDOM%9999+1)))
token=$(env LC_CTYPE=C tr -dc "a-zA-Z0-9-_\$\?" < /dev/urandom | head -c 48)
prefix="aci"
location="eastus"
resource_group="$prefix-$id"
vault_name="$prefix-vault-$id"
sa_name="${prefix}sa${id}"
key_vault_name="$prefix-kv-$id"
user_identity="${prefix}vault${id}"
tenantId=$(az account show --query tenantId -o tsv)

# Create a self-signed certificate
openssl req -newkey rsa:4096 \
            -x509 \
            -sha256 \
            -days 3650 \
            -nodes \
            -out vault-cert.crt \
            -keyout vault-cert.key \
            -subj "/C=SI/ST=Encrypted/L=Frazzled/O=Security/OU=IT Department/CN=${vault_name}.eastus.azurecontainer.io"

# Create resource group
az group create --name $resource_group --location $location

# Create storage account for persistence
sa_account=$(az storage account create  --resource-group $resource_group \
  --name $sa_name --sku Standard_LRS)

az storage share create --account-name $sa_name --name vault-data

az storage directory create --account-name $sa_name --share-name vault-data --name certs

az storage file upload --account-name $sa_name --share-name vault-data --source vault-config.hcl 
az storage file upload --account-name $sa_name --share-name vault-data --source vault-cert.crt --path certs
az storage file upload --account-name $sa_name --share-name vault-data --source vault-cert.key --path certs

keys=$(az storage account keys list -g $resource_group  -n $sa_name)

key=$(echo $keys | jq '.[0].value' -r)

# Create a User Identity
user_id=$(az identity create -g $resource_group -n $user_identity)
principal_id=$(echo $user_id | jq '.principalId' -r)
user_id=$(echo $user_id | jq '.id' -r)

# Create a Key Vault
az keyvault create --resource-group $resource_group \
  --name $key_vault_name --location $location --sku standard

az keyvault key create --vault-name $key_vault_name --name vault-key

# Great User Identity Access to Key Vault
az keyvault set-policy --name $key_vault_name \
  --object-id $principal_id \
  --resource-group $resource_group \
  --key-permissions get list create delete update wrapKey unwrapKey

# Create aci instance
az container create --resource-group $resource_group \
  --name $vault_name --image vault:1.5.3 \
  --command-line 'vault server -config /vault/vault-config.hcl' \
  --dns-name-label $vault_name --ports 8200 \
  --azure-file-volume-account-name $sa_name \
  --azure-file-volume-share-name vault-data \
  --azure-file-volume-account-key $key \
  --azure-file-volume-mount-path /vault \
  --assign-identity $user_id \
  --environment-variables AZURE_TENANT_ID=$tenantId \
  VAULT_AZUREKEYVAULT_VAULT_NAME=$key_vault_name \
  VAULT_AZUREKEYVAULT_KEY_NAME=vault-key

# Set the environment variables
export VAULT_ADDR="https://${vault_name}.eastus.azurecontainer.io:8200"
export VAULT_SKIP_VERIFY=true

vault status

vault operator init -recovery-shares=1 -recovery-threshold=1 

# Make note of the Recovery Key and Root Token

vault login

# Now delete the container
az container delete --resource-group $resource_group --name $vault_name

# Delete the resource group if you're done
