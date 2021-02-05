## Set the version of Consul
CONSUL_VERSION=1.7.3

## Download consul and start the service
wget -O consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
unzip consul.zip
rm consul.zip
./consul agent -dev > consul_logs &

## Push some configuration settings to Consul
curl --request PUT --data "10.0.0.0/16" http://127.0.0.1:8500/v1/kv/terraform/vpc/development/cidr_range
curl --request PUT --data "10.1.0.0/16" http://127.0.0.1:8500/v1/kv/terraform/vpc/staging/cidr_range
curl --request PUT --data "10.2.0.0/16" http://127.0.0.1:8500/v1/kv/terraform/vpc/production/cidr_range

## Run terraform init and apply

terraform init
terraform apply

## Create a new workspace

terraform workspace new development
terraform apply

## Create a new workspace

terraform workspace new staging
terraform apply