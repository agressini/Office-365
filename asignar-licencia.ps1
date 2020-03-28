param (
    [string]$Filename = "",
    [string]$Licencia = ""    
)
$P1 = Get-MsolGroup –ObjectId 198bbe94-19b4-4c0e-af7c-a01dcf28d262
$P2 = Get-MsolGroup –ObjectId 06529a35-d3bf-4419-bd9e-7a9b28cfb670
$E3 = Get-MsolGroup –ObjectId 78e120b3-3f28-44ff-bb42-e6083bb24b11

Import-CSv -Path $Filename | ForEach-Object {
    $Users=Get-MsolUser -UserPrincipalName $_.EmailAddress
    switch ($licencia) {
        "P1" {Add-MsolGroupMember -GroupObjectId $P1.ObjectID -GroupMemberObjectId $Users.ObjectID -GroupMemberType User;Break}
        "P2" {Add-MsolGroupMember -GroupObjectId $P2.ObjectID -GroupMemberObjectId $Users.ObjectID -GroupMemberType User;Break}
        "E3" {Add-MsolGroupMember -GroupObjectId $E3.ObjectID -GroupMemberObjectId $Users.ObjectID -GroupMemberType User;Break}
        Default {Write-Host "debe elegir entre los valores de licencia posible P1 P2 y E3";Break}
    }
}

