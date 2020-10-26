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
az keyvault secret download --name "boundary1" --vault-name "boundary1" --file certdata.pem --encoding base64
sudo openssl pkcs12 -in certdata.pem -out /etc/pki/tls/boundary/cert.key -nocerts -nodes -passin pass:
sudo openssl pkcs12 -in certdata.pem -out /etc/pki/tls/boundary/cert.crt -clcerts -nokeys -passin pass:
rm certdata.pem
