# Deploying Vault and Consul HCP on AWS

Hi! In this demo I am going to deploy both Vault and Consul on HashiCorp Cloud Platform. What does that mean? Let's dig in.

## HashiCorp Cloud Platform

HashiCorp Cloud Platform (HCP) provides HashiCorp software as a service. Currently, Vault and Consul are both generally available on AWS. The eventual plan is to make the hosted service available on all major cloud platforms. There is already a HashiCorp Consul Service on Azure that is offered directly through the Azure marketplace. HCP is different in that it uses its own portal to manage deployments. The Azure offering is offered and managed through Azure. 

### Components

The services offered by HCP are deployed into a managed network construct in your cloud of choice. The network abstraction is called a HashiCorp Virtual Network (HVN). On AWS - the only cloud provider currently available - this takes the form of a VPC managed by HashiCorp. You access the services in the HVN through either a private or public URL. The private URL is accessible by creating a peering connecting between the HVN and your other VPCs. The practical implication is that you need to select a CIDR range for the HVN that does not conflict with any of the VPCs you wish to peer with. HVN also supports Transit Gateway, removing the need to create a peering connection with every VPC.

The public URL is exactly what it implies, a publicly accessible URL to the managed service. If you want to consume the service outside of a specific cloud provider, then the public URL is probably the way to go. As of right now, there is no way to configure firewall rules to limit accessiblity of the public URL. Maybe that will be in a future release? In terms of implementation, that should be relatively simple to do with Security Groups and Network ACLs on the VPC hosting the services.

Vault and Consul both run as a managed service in the HVN. You can choose to provision a Development or Standard cluster. For this demo I am going with the Development cluster, which is a single node deployment. The cost is super low (a few pennies an hour) and covered by the $50 credit you get when signing up for the service.

## Demo

The demo files will deploy the following resources:

* One or more AWS VPCs in a region of your choosing
* An HVN instance
* Peering connections from the VPCs to the HVN
* A development instance of Vault
* A development instance of Consul
* An EC2 instance in each VPC to test access to Vault and Consul

There are modules for the HVN, Consul, Vault, and network peering resources. You can take these modules and use them for your existing environment if you'd like.

Right now the EC2 instances are deployed in public subnets with port 22 open to anyone. That was done for simplicity and is not a recommended configuration for any production deployment (obviously). The config also updates the routing table for the public subnets with a route to the HVN across the peering connection. Other route tables are not updated. 

The EC2 instance is prepped by installing the Vault and Consul binaries, and writing config information to the instance. The Vault address and admin token are written out to files in the home directory of the `ec2-user` account. The Consul agent configuration is written out to `/opt/consul`.

### Pre-requisites

Here's what you'll need to set up to follow along:

* An HCP account and service principal with a `client_id` and `client_secret`
* An AWS account for the VPC and EC2 deployments with an `access_key` and `secret_key`
* A key pair for the AWS region where you will create the EC2 instances
* A Terraform Cloud account for remote state storage

### Remote State

The demo uses Terraform Cloud for remote state. You will need to set up a workspace, variables, and environment variables. The following variables will be used:

* `keyname` - The name of the EC2 key pair to use for SSH access
* `client_id` - The client ID of the service principal in HCP
* `client_secret` - The client secret of the service principal in HCP

I marked both the `client_id` and `client_secret` as *sensitive*.

The following environment variables are used for the AWS provider:

* `AWS_ACCESS_KEY_ID` - Access key for AWS account
* `AWS_SECRET_ACCESS_KEY` - Secret access key for AWS account

I marked both environment variables as *sensitive* as well.

There are other variable values you may wish to change, like the region used in AWS or the CIDR block for the HVN. You could also take the modules and use them with your own VPCs.

### Outputs and Timing

The output of the `terraform apply` will include the admin tokens for both services and the public IP addresses for all EC2 instances created. You should be able to SSH into each EC2 instance with the key pair specified in the config.

A full deployment is going to take at least 10-15 minutes due to the time it takes to provision Vault and Consul clusters. Don't worry! Nothing is wrong, it just takes a bit.

### Commands once logged into EC2 instance

To get connected to the Vault instance once you are logged into an EC2 instance, run the following commands:

```
export VAULT_ADDR=$(cat vault_address)
export VAULT_TOKEN=$(cat vault_token)

vault status
```

To use Consul, you can get the Consul agent on the EC2 instance started by running the following:

```
sudo consul agent -config-dir=/opt/consul -data-dir=/opt/consul &

consul members -token $(cat consul_token)
```

