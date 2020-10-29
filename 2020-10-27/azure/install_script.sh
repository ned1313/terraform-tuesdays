#!/bin/bash

# Install Azure CLI
sudo apt-get update
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg -y
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install azure-cli jq -y

# Get certificates from Key Vault
sudo mkdir -p /etc/pki/tls/boundary
az login --identity --allow-no-subscriptions
az keyvault secret download --name ${cert_name} --vault-name ${vault_name} --file certdata.pem --encoding base64
sudo openssl pkcs12 -in certdata.pem -out /etc/pki/tls/boundary/cert.key -nocerts -nodes -passin pass:
sudo openssl pkcs12 -in certdata.pem -out /etc/pki/tls/boundary/cert.crt -clcerts -nokeys -passin pass:
rm certdata.pem

# Get boundary binary
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install boundary

# Get private ip address
private_ip=$(hostname -i | awk '{print $1}')

# Create controller config
%{ if ${type} == "controller"}
cat <<EOF > ~/boundary-controller.hcl
disable_mlock = true

telemetry { 
  prometheus_retention_time = "24h"
  disable_hostname          = true
}

controller {
  name        = "demo-controller-$(hostname)"
  description = "A controller for a demo!"

  database {
    url = "postgresql://${db_endpoint}:5432/postgres?user=${db_username}&password=${db_password}&sslmode=require"
  }
}

listener "tcp" {
  address                           = "$private_ip:9200"
	purpose                           = "api"
  tls_disable   = false
  tls_cert_file = "/etc/pki/tls/boundary/cert.crt"  
  tls_key_file  = "/etc/pki/tls/boundary/cert.key"
	# proxy_protocol_behavior         = "allow_authorized"
	# proxy_protocol_authorized_addrs = "127.0.0.1"
	cors_enabled                      = true
	cors_allowed_origins              = ["*"]
}

listener "tcp" {
  address                           = "$private_ip:9201"
	purpose                           = "cluster"
  tls_disable   = false
  tls_cert_file = "${tls_cert_path}"  
  tls_key_file  = "${tls_key_path}"
	# proxy_protocol_behavior         = "allow_authorized"
	# proxy_protocol_authorized_addrs = "127.0.0.1"
}

kms "azurekeyvault" {
	purpose    = "root"
	tenant_id     = "${tenant_id}"
    vault_name = "${vault_name}"
    key_name = "${root_key_name}"
}

kms "azurekeyvault" {
	purpose    = "worker-auth"
	tenant_id     = "${tenant_id}"
    vault_name = "${vault_name}"
    key_name = "${worker_key_name}"
}

kms "azurekeyvault" {
    purpose = "recovery"
	tenant_id     = "${tenant_id}"
    vault_name = "${vault_name}"
    key_name = "${recovery_key_name}"
}
EOF

sudo mv ~/boundary-controller.hcl /etc/boundary-controller.hcl

# Installs the boundary as a service for systemd on linux
TYPE=controller
NAME=boundary

%{endif}

%{ if ${type} == "worker"}

TYPE=worker
NAME=boundary

# Create worker config
cat <<EOF > ~/boundary-worker.hcl

listener "tcp" {
  address = "$private_ip:9202"
	purpose = "proxy"
  tls_disable   = false
  tls_cert_file = "/etc/pki/tls/boundary/cert.crt"   
  tls_key_file  = "/etc/pki/tls/boundary/cert.key" 

	#proxy_protocol_behavior = "allow_authorized"
	#proxy_protocol_authorized_addrs = "127.0.0.1"
}

worker {
  # Name attr must be unique
	public_addr = "${public_ip}"
	name = "demo-worker-$(hostname)"
	description = "A default worker created for demonstration"
	controllers = [
%{ for ip in controller_ips ~}
    "${ip}",
%{ endfor ~}
  ]
}

kms "azurekeyvault" {
	purpose    = "worker-auth"
	tenant_id     = "${tenant_id}"
    vault_name = "${vault_name}"
    key_name = "${worker_key_name}"
}
EOF

sudo mv ~/boundary-worker.hcl /etc/boundary-worker.hcl

# Installs the boundary as a service for systemd on linux
TYPE=worker
NAME=boundary

%{endif} 

sudo cat << EOF > ~/${NAME}-${TYPE}.service
[Unit]
Description=${NAME} ${TYPE}

[Service]
ExecStart=/usr/bin/${NAME} server -config /etc/${NAME}-${TYPE}.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

sudo mv ~/${NAME}-${TYPE}.service /etc/systemd/system/${NAME}-${TYPE}.service

# Add the boundary system user and group to ensure we have a no-login
# user capable of owning and running Boundary
sudo adduser --system --group boundary || true
sudo chown boundary:boundary /etc/${NAME}-${TYPE}.hcl
sudo chown boundary:boundary /usr/bin/boundary
sudo chown boundary:boundary /etc/pki/tls/boundary/cert.crt
sudo chown boundary:boundary /etc/pki/tls/boundary/cert.key


# Make sure to initialize the DB before starting the service. This will result in
# a database already initizalized warning if another controller or worker has done this 
# already, making it a lazy, best effort initialization
if [ "${TYPE}" = "controller" ]; then
  sudo /usr/bin/boundary database init -skip-auth-method-creation -skip-host-resources-creation -skip-scopes-creation -skip-target-creation -config /etc/${NAME}-${TYPE}.hcl || true
fi

sudo chmod 664 /etc/systemd/system/${NAME}-${TYPE}.service
sudo systemctl daemon-reload
sudo systemctl enable ${NAME}-${TYPE}
sudo systemctl start ${NAME}-${TYPE}