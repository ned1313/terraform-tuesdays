# Copied from the Vault OIDC tutorial
# https://learn.hashicorp.com/tutorials/vault/oidc-auth-azure?in=vault/auth-methods

# And from the OIDC Boundary OIDC tutorial
# https://learn.hashicorp.com/tutorials/boundary/oidc-auth

# Start up Boundary in dev mode - don't worry we'll do this in Azure at some point
boundary dev

# Get the OIDC auth method id
auth_method_id=$(boundary auth-methods list -format=json | jq '.items[] | select(.type == "oidc") | .id' -r)

# Authenticate with the basic OIDC method

boundary authenticate oidc -auth-method-id $auth_method_id

# You may need to save the resultant token to BOUNDARY_TOKEN

export BOUNDARY_TOKEN=<token value>

# Set the BOUNDARY ADDRESS
export BOUNDARY_ADDR=http://127.0.0.1:9200

# Set the Display Name for Azure AD Application
unique_id=$(openssl rand -hex 4)
export AD_AZURE_DISPLAY_NAME="boundary-$unique_id"

# Create the Azure web app
# We will update the reply urls later
export AD_BOUNDARY_APP_ID=$(az ad app create \
   --display-name ${AD_AZURE_DISPLAY_NAME} | \
   jq -r '.appId')

# Get the Microsoft Graph API ID
export AD_MICROSOFT_GRAPH_API_ID=$(az ad sp list \
   --filter "displayName eq 'Microsoft Graph'" \
   --query '[].appId' -o tsv)

# Get the READ ALL group member ID
export AD_PERMISSION_GROUP_MEMBER_READ_ALL_ID=$(az ad sp show \
   --id ${AD_MICROSOFT_GRAPH_API_ID} \
   --query "oauth2Permissions[?value=='GroupMember.Read.All'].id" -o tsv)

# Add the proper permissions to the web app we created
az ad app permission add \
   --id ${AD_BOUNDARY_APP_ID} \
   --api ${AD_MICROSOFT_GRAPH_API_ID} \
   --api-permissions ${AD_PERMISSION_GROUP_MEMBER_READ_ALL_ID}=Scope

# Create a service principal for our web app so it can access the graph API
az ad sp create --id ${AD_BOUNDARY_APP_ID}

# Grant ye olde permission with new command!
az ad app permission grant \
  --id ${AD_BOUNDARY_APP_ID} \
  --api ${AD_MICROSOFT_GRAPH_API_ID}

# Now we need our Azure AD tenant id, let's grab that
export AD_TENANT_ID=$(az ad sp show --id ${AD_BOUNDARY_APP_ID} \
   --query 'appOwnerTenantId' -o tsv)

# And finally we should get a new secret for our service principal
export AD_CLIENT_SECRET=$(az ad app credential reset \
    --id ${AD_BOUNDARY_APP_ID} | jq -r '.password')

# Alright, we have everything we need to enable the OIDC auth method in Boundary

boundary auth-methods create oidc \
  -issuer "https://login.microsoftonline.com/${AD_TENANT_ID}/v2.0" \
  -client-id ${AD_BOUNDARY_APP_ID} \
  -client-secret ${AD_CLIENT_SECRET} \
  -signing-algorithm RS256 \
  -api-url-prefix "http://localhost:9200" \
  -name "azuread"

# Now we need to update our web app with the callback url from our new auth method
callback_url=$(boundary auth-methods list -format=json | jq '.items[] | select(.name == "azuread") | .attributes.callback_url' -r)

az ad app update --id ${AD_BOUNDARY_APP_ID} --reply-urls $callback_url

# Finally let's activate our new auth method
azuread_method_id=$(boundary auth-methods list -format=json | jq '.items[] | select(.name == "azuread") | .id' -r)

boundary auth-methods change-state oidc -id $azuread_method_id -state active-public

# To auto create users, we need to make this auth method the primary method

boundary scopes update -primary-auth-method-id $azuread_method_id -id global

boundary authenticate oidc -auth-method-id $azuread_method_id

# And now our authentication is successful! Good job everyone.

# Next steps: Instantiate this workflow using Terraform
