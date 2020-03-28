$userUPN = "areid@contoso.com"
$guid = [guid]((Get-ADUser -LdapFilter "(userPrincipalName=$userUPN)").objectGuid)
$immutableId = [System.Convert]::ToBase64String($guid)

Get-MsolUser -UserPrincipalName $userUPN | Set-MsolUser -ImmutableId $immutableId

Start-ADSyncSyncCycle -PolicyType Initial