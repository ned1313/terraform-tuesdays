#Bash
key_id="KEY_ID"
cipher_blob="RESOURCE_CIPHER_TEXT"
aws kms decrypt --ciphertext-blob $cipher_blob --key-id $key_id

echo "PLAINTEXT" | base64 -d

#PowerShell
$key_id="KEY_ID"
$cipher_blob="RESOURCE_CIPHER_TEXT"

aws kms decrypt --ciphertext-blob $cipher_blob --key-id $key_id

[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(PLAINTEXT))