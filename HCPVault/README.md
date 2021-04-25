# Commands once logged into EC2 instance

export VAULT_ADDR=$(cat vault_address)
export VAULT_TOKEN=$(cat vault_token)

sudo consul agent -config-dir=/opt/consul -data-dir=/opt/consul &

