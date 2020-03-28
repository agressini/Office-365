##If Execution policy is different to signed execute Set-ExecutionPolicy RemoteSigned
$Cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session
Get-IRMConfiguration
##AzureRMSLicensingEnabled value: if false execute Set-IRMConfiguration -AzureRMSLicensingEnabled $true
Test-IRMConfiguration -Sender <user email address>