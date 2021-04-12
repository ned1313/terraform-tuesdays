# First we need to create a key and an alias for the key

#Bash

key_data=$(aws kms create-key --description "S3 SSE Key" --output json)
aws kms create-alias --alias-name alias/s3SseKey --target-key-id $(echo $key_data | jq .KeyMetadata.KeyId -r)

# PowerShell

$key_data = aws kms create-key --description "S3 SSE Key" --output json | ConvertFrom-Json
aws kms create-alias --alias-name alias/s3SseKey --target-key-id $($key_data.KeyMetadata.KeyId)