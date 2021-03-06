# Let's get the file and move it to /usr/local/bin

wget https://releases.hashicorp.com/consul-terraform-sync/0.1.0-beta/consul-terraform-sync_0.1.0-beta_linux_amd64.zip
unzip consul-terraform-sync_0.1.0-beta_linux_amd64.zip
rm consul-terraform-sync_0.1.0-beta_linux_amd64.zip
sudo mv consul-terraform-sync /usr/local/bin/

# And check to make sure we have the right version
consul-terraform-sync --version

# Now we need to get Terraform and Consul into the picture
# Oh and we need an environment to control
# And an application to register with Consul

