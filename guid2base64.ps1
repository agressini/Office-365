Import-Module ActiveDirectory
$Users=Get-ADUser -Filter *
 
function guidtobase64
{
    param($str);
    $g = new-object -TypeName System.Guid -ArgumentList $str;
    $b64 = [System.Convert]::ToBase64String($g.ToByteArray());
    return $b64;
}
$ADUsersDump=$Users | Select SamAccountName,UserPrincipalName,@{Expression={(guidtobase64($_.ObjectGUID))}; Label="ImmutableID"}
$ADUsersDump
$ADUsersDump >ImmutableIDs.txt
notepad ImmutableIDs.txt