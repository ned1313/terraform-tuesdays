# We're going to assume you already have a Kubernetes cluster and kubectl

# Create a namespace for your Kubernetes operator
kubectl create namespace tfops

# Update the credentials.example file and rename credentials then create a K8s secret
kubectl create -n tfops secret generic terraformrc --from-file=credentials=credentials

# Now we need to create a service principal to create our Azure infra
az login
az account set -s SUB_NAME

# Get your sub ID
subId=$(az account show --query id -o tsv)

# Create your SP and save info in env-variables.yaml
sp=$(az ad sp create-for-rbac --name tfops-sp --role contributor --scopes "subscriptions/$subId/")

client_id=$(echo $sp | jq .appId -r)
client_secret=$(echo $sp | jq .password -r)
tenant_id=$(echo $sp | jq .tenant -r)

# Create an env-variables configmap for your non-secret values
cat > env-variables.yaml <<EOF
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: azure-configuration
data:
  arm_tenant_id: $tenant_id
  arm_subscription_id: $subId
  arm_client_id: $client_id
EOF

# Create the config map
kubectl apply -f env-variables.yaml -n tfops

# Create a secret for the client_secret
kubectl create secret -n tfops generic workspacesecrets --from-literal=ARM_CLIENT_SECRET=$client_secret

# Install the terraform operator
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/terraform --devel
helm install --devel --namespace tfops hashicorp/terraform --generate-name

# Edit the vnet.yaml as needed for your organization
kubectl apply -f vnet.yaml -n tfops

# Validate the process
kubectl describe workspace -n tfops vnet-new

# Delete the workspace
# Uncomment the CONFIRM_DESTROY value
# Reapply and then delete
kubectl apply -f vnet.yaml -n tfops

kubectl delete -f vnet.yaml -n tfops
