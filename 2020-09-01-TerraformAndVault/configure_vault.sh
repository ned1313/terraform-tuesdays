# Create an AWS profile if you don't have one
aws configure

# Create the vault-account IAM user

vaultacct=$(aws iam create-user --user-name=vault-account)
vaultarn=$(echo $vaultacct | jq .User.Arn -r)


# Create the role with an assume policy
cat << EOF > assume_policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "$vaultarn"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF

ec2admin=$(aws iam create-role --role-name=ec2-admin --assume-role-policy-document=file://assume_policy.json)

# Grant the role the AmazonEC2FullAccess permission

aws iam attach-role-policy --role-name=ec2-admin --policy-arn=arn:aws:iam::aws:policy/AmazonEC2FullAccess

# Create the allow policy
ec2adminarn=$(echo $ec2admin | jq .Role.Arn -r)

cat << EOF > allow_role.json
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "$ec2adminarn"
  }
}
EOF

allow_policy=$(aws iam create-policy --policy-name=allow-vault-ec2-admin --policy-document=file://allow_role.json)
allow_policy_arn=$(echo $allow_policy | jq .Policy.Arn -r)

aws iam attach-user-policy --user-name=vault-account --policy-arn=$allow_policy_arn

# Get an access token for the vault-account to use with vault
access_key=$(aws iam create-access-key --user-name=vault-account)
key=$(echo $access_key | jq .AccessKey.AccessKeyId -r)
secret=$(echo $access_key | jq .AccessKey.SecretAccessKey -r)

export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN=TOKEN_VALUE

vault login

vault secrets enable aws

vault write aws/config/root \
    access_key=$key \
    secret_key=$secret \
    region=us-east-1

vault write aws/roles/ec2-admin\
    role_arns=$ec2adminarn \
    credential_type=assumed_role


vault kv put secret/appkey mykey=1234567890

terraform init

terraform apply -auto-approve