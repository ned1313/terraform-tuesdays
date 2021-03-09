#!/bin/bash

# Start by installing Terraform and Consul from package manager
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt update
sudo apt install terraform consul jq unzip apache2 -y

# Create config file for Consul and data directory

sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul

cat <<EOF > ~/server.hcl
datacenter = "dc1"
data_dir = "/opt/consul"
server = true
bootstrap_expect = 1
retry_join = ["127.0.0.1"]
client_addr = "0.0.0.0"
ui = true
acl = {
    enabled = true
    default_policy = "allow"
    enable_token_persistence = true
}
EOF

sudo mv ~/server.hcl /etc/consul.d/server.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/server.hcl

cat <<EOF > ~/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF


sudo mv ~/consul.service /usr/lib/systemd/system/consul.service
sudo systemctl enable consul
sudo systemctl start consul

sleep 10

consul acl bootstrap -format=json > /opt/consul/bootstrap.token
SECRET_ID=$(cat /opt/consul/bootstrap.token | jq .SecretID -r)

export CONSUL_HTTP_TOKEN=$SECRET_ID
export CONSUL_MGMT_TOKEN=$SECRET_ID

# Consul install complete

# Register the apache web service with Consul

# Get the local ip address
local_ip=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

consul services register -address=$local_ip -name=web -port=80 -meta=VSIP=${big_ip_address} -meta=VSPORT=80 -meta=AS3TMPL=http

# Now generate a token for CTS
consul acl token create -policy-name=global-management -format=json > /opt/consul/cts.token
CTS_TOKEN=$(cat /opt/consul/cts.token | jq .SecretID -r)

# Next we will create our CTS config file using the token just generated

cat <<EOF > /opt/consul/cts_config.hcl
log_level = "INFO"
port = 8558

consul {
    address = "localhost:8500"
    token = "$CTS_TOKEN"
}

service {
    name = "web"
    datacenter = "dc1"
    description = "Web server running on Azure VM"
}

task {
    name = "F5"
    description = "Configure F5 firewall"
    enabled = true
    services = ["web"]
    providers = ["bigip"]
    source = "f5devcentral/app-consul-sync-nia/bigip"
    version = "0.1.2"
}

driver "terraform" {
    log = true
    path = "/usr/bin/"
    required_providers {
        bigip = {
            source = "F5Networks/bigip"
        }
    }
}

terraform_provider "bigip" {
    address = "${big_ip_address}:8443"
    username = "admin"
    password = "${big_ip_password}"
}

EOF

# Now get the version of CTS
CTS_VERSION=0.1.0
wget https://releases.hashicorp.com/consul-terraform-sync/0.1.0-beta/consul-terraform-sync_$CTS_VERSION-beta_linux_amd64.zip
unzip consul-terraform-sync_0.1.0-beta_linux_amd64.zip
rm consul-terraform-sync_0.1.0-beta_linux_amd64.zip
sudo mv consul-terraform-sync /usr/local/bin/

# Now get CTS running
# consul-terraform-sync -config-file ~/cts_config.hcl