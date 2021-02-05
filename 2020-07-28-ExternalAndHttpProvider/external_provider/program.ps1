$jsonpayload = [System.Console]::In.ReadLine()

$json = ConvertFrom-Json $jsonpayload

$name = $json.name

Write-Output @"
{ "Message": "Hello $name"}
"@
