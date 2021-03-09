Laying down some sweet notes over here

Here's the plan

Deploying an F5 LB in Azure
Deploy a VM running Consul, CTS, and Terraform
Deploy a VM running a basic web application
Register app with Consul
Have F5 open port 80 on LB to said APP using CTS

What do you need to do?

Step 1 - Enable programmatic deployment of the F5 Per-App Virtual Edition PAYG
Step 2 - Deploy the test environment from the environment directory
Step 3 - Check config of F5
Step 4 - Register application with Consul
Step 5 - Check config of F5

Install AS3 on F5
https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.26.0/f5-appsvcs-3.26.0-5.noarch.rpm


Once the terraform deployment is complete, now we're ready to get the F5 configured. All we need to do is change the password to what it is set in the configuration.

```bash
# Move the private key to your home .ssh directory
cp cts_private_key.pem ~/.ssh/

# Change permissions if you're on Linux
chmod 600 ~/.ssh/cts_private_key.pem

ssh admin@PUBLIC_IP_ADDRESS -i ~/.ssh/cts_private_key.pem

# Now you'll be logged into F5 we're going to change the password
modify auth password admin

# Once you're done setting the password, you can exit the device
quit

# Now we're going to install the AS3 template
wget https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.26.0/f5-appsvcs-3.26.0-5.noarch.rpm

FN=f5-appsvcs-3.26.0-5.noarch.rpm

CREDS=admin:password

IP=IP address of BIG-IP

LEN=$(wc -c $FN | awk 'NR==1{print $1}')

curl -kvu $CREDS https://$IP:8443/mgmt/shared/file-transfer/uploads/$FN -H 'Content-Type: application/octet-stream' -H "Content-Range: 0-$((LEN - 1))/$LEN" -H "Content-Length: $LEN" -H 'Connection: keep-alive' --data-binary @$FN

DATA="{\"operation\":\"INSTALL\",\"packageFilePath\":\"/var/config/rest/downloads/$FN\"}"


curl -kvu $CREDS "https://$IP:8443/mgmt/shared/iapp/package-management-tasks" -H "Origin: https://$IP:8443" -H 'Content-Type: application/json;charset=UTF-8' --data $DATA

rm $FN
```

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

