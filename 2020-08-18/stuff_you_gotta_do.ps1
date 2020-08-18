winrm quickconfig

winrm set winrm/config/service '@{AllowUnencrypted="true"}'

winrm set winrm/config/service/Auth '@{Basic="true"}'

$adminUser = Get-Credential

$env:TF_VAR_winrm_username = $adminUser.Username

$env:TF_VAR_winrm_password = $adminUser.GetNetworkCredential().Password