Laying down some sweet notes over here

Here's the plan

Deploying an F5 LB in Azure
Deploy a VM running Consul, CTS, Terraform, and Web Server
Register app with Consul
Have F5 open port 80 on LB to said APP using CTS

What do you need to do?

Step 1 - Enable programmatic deployment of the F5 Per-App Virtual Edition PAYG
Step 2 - Deploy the test environment from the environment directory
Step 3 - Update config of F5
Step 4 - Check config of F5

Install AS3 on F5
https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.26.0/f5-appsvcs-3.26.0-5.noarch.rpm


Once the terraform deployment is complete, now we're ready to get the F5 configured. All we need to do is change the password to what it is set in the configuration.

```bash
ssh admin@PUBLIC_IP_ADDRESS -i PATH_TO_PRIVATE_KEY

# Now you'll be logged into F5 we're going to change the password
modify auth password admin

# Once you're done setting the password, you can exit the device
quit

# Now we're going to install the AS3 template
wget https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.26.0/f5-appsvcs-3.26.0-5.noarch.rpm

chmod a+x install-rpm.sh

./install-rpm.sh PUBLIC_IP_ADDRESS admin:PASSWORD f5-appsvcs-3.26.0-5.noarch.rpm

rm f5-appsvcs-3.26.0-5.noarch.rpm
```

The F5 is all set. Now we SSH into the CTS server and kick off the CTS sync.

```bash
consul-terraform-sync -config-file /opt/consul/cts_config.hcl
```