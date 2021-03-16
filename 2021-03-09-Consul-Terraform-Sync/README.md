# Introduction

Consul-Terraform-Sync (CTS) is meant to synchronize changes detected by Consul services to external network devices that do not integrate with Consul. In this iteration, Consul is leveraging the providers from Terraform to initiate changes on network devices. A common operation might be adding entries to a load balancer when a service is turned up or changed.

It's not a completely smooth flow, as CTS needs to know about the Consul services to monitor, and the services need the proper metadata for the network devices they are going to alter. Once the initial connection is complete, I think ongoing and dynamic changes would be easier.

# Demonstration

To demonstrate the process, we are going to deploy an Azure VM running Consul, CTS, and a web server. We will also deploy an F5 BIG-IP load balancer in the same virtual network. The load balancer will be the target network device we want to update using CTS. Why F5? Well, it was one of the supported vendors and it has a marketplace image in Azure. Path of least resistance on that one.

Here's the planned steps:

* Deploying an F5 LB in Azure
* Deploy a VM running Consul, CTS, Terraform, and Web Server
* Register app with Consul
* Have F5 open port 80 on LB to said APP using CTS

What do you need to do?

Step 1 - Enable programmatic deployment of the F5 Per-App Virtual Edition PAYG
Step 2 - Deploy the test environment from the environment directory
Step 3 - Update config of F5
Step 4 - Check config of F5

## Step 1 - Programmatic deployment of F5 BIG-IP

In Azure, when you want to deploy something from the marketplace to a subscription, you first have to enable it for programmatic deployment. You can do this from the portal by searching for the F5 Per-App Virtual Edition (PAYG) offer. Or you can enable from the command line using the Azure CLI with the following command:

```bash
az vm image terms accept --urn f5-networks:f5-big-ip-per-app-ve:f5-big-awf-plus-pve-hourly-200mbps:latest
```

Make sure you have the right subscription selected before running the command. This needs to be run on each subscription you want to enable for programmatic deployment. Yes, yes, I know. It is a pain.

## Step 2 - Deploy the infrastructure

This part is simple. Go into the `environment` subfolder and run the standard Terraform commands:

```bash
terraform init
terraform plan -out cts.tfplan
terraform apply cts.tfplan
```

You may want to change the region or resource group naming. But you don't need to!

## Step 3 - Update the F5 config


Once the terraform deployment is complete, now we're ready to get the F5 configured. All we need to do is change the password to what it is set in the configuration.

```bash
# Move the private key to your home .ssh directory
cp cts_private_key.pem ~/.ssh/

# Change permissions if you're on Linux
chmod 600 ~/.ssh/cts_private_key.pem

ssh admin@F5_PUBLIC_IP_ADDRESS -i ~/.ssh/cts_private_key.pem

# Now you'll be logged into F5 we're going to change the password
modify auth password admin

# Once you're done setting the password, you can exit the device
quit

# Now we're going to install the AS3 template
wget https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.26.0/f5-appsvcs-3.26.0-5.noarch.rpm

FN=f5-appsvcs-3.26.0-5.noarch.rpm

CREDS=admin:password

IP=Public IP address of BIG-IP

LEN=$(wc -c $FN | awk 'NR==1{print $1}')

curl -kvu $CREDS https://$IP:8443/mgmt/shared/file-transfer/uploads/$FN -H 'Content-Type: application/octet-stream' -H "Content-Range: 0-$((LEN - 1))/$LEN" -H "Content-Length: $LEN" -H 'Connection: keep-alive' --data-binary @$FN

DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$FN\"}"


curl -kvu $CREDS "https://$IP:8443/mgmt/shared/iapp/package-management-tasks" -H "Origin: https://$IP:8443" -H 'Content-Type: application/json;charset=UTF-8' --data $DATA

rm $FN
```

## Step 4 - Update the Azure VM config
The F5 is all set. Now we SSH into the CTS server and kick off the CTS sync.

```bash
consul-terraform-sync -config-file /opt/consul/cts_config.hcl &
```

Finally we can check on the F5 and make sure everything was created successfully.

If we want to test the update process, all we have to do is make a change to the current service config on Consul:

```bash
SECRET_ID=$(cat /opt/consul/bootstrap.token | jq .SecretID -r)

export CONSUL_HTTP_TOKEN=$SECRET_ID
export CONSUL_MGMT_TOKEN=$SECRET_ID

consul services register -address=10.0.0.10 -name=web -port=80 -meta=VSIP=BIG_IP_INTERNAL_ADDRESS -meta=VSPORT=80 -meta=AS3TMPL=http
```

# Conclusion

That should do it! At least I hope so. This product is still VERY much in beta, so expect breaking changes and lots of updates in the future. You can find the latest docs on the [Consul website](https://www.consul.io/docs/nia/installation/install).
