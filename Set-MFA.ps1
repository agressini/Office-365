param ( 
    [string]$ImportPath="")

$Module = Get-Module -Name MSOnline
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
#$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

If ($Module.Name -ne "MSOnline")
{
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) 
    {
        Install-Module MSOnline
    }
    else
    {
        Write-Host "Debe ejecutarse como administrador" -BackgroundColor Black -ForegroundColor Red
    }
        
}

Connect-MsolService


# Define your list of users to update state in bulk "bsimon@contoso.com","jsmith@contoso.com","ljacobson@contoso.com"
$Users = Get-Content -Path $ImportPath

foreach ($User in $Users)
{
    $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
    $st.RelyingParty = "*"
    $st.State = "Enabled"
    $sta = @($st)
    Set-MsolUser -UserPrincipalName $user -StrongAuthenticationRequirements $sta
    #Get-MsolUser -UserPrincipalName $User 
}

#Disable
#Get-MsolUser -UserPrincipalName bsimon@contoso.com | Set-MsolUser -StrongAuthenticationRequirements @()


