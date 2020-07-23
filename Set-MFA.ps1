param (
    [Parameter(Mandatory=$true,Position=0)]
    [ValidateSet("ReportOnly","EnableMFA","DisableMFA")]
    [string]
    $Mode = "ReportOnly",

    [Parameter(Mandatory=$false,Position=1)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ImportFile,
    [Parameter(Mandatory=$false,Position=2)]
    [ValidateNotNullOrEmpty()]
    [string]
    $UPN
    )

Import-Module -Name MSonline
Write-Host "Seting up Variables..." -ForegroundColor Yellow
$Now = Get-Date
$ExportPath = "$env:USERPROFILE\Downloads\"
$logPath = ($ExportPath + "MFA_OPS-log.txt")
$ReportPath = $ExportPath + "Report_MFA_USERS" +($Now).ToString("yyMMddhhmm") + ".csv"
$Module = Get-Module -Name MSOnline
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

try {
        
    If ($Module.Name -eq "MSOnline")
    {
        Write-Host "Conectando a MS Online: "
        "Conectando a MS Online!" | Out-File -Encoding utf8 -FilePath $logPath -Append
        Connect-MsolService
    }   
    elseif ($Module.Name -ne "MSOnline" -and $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Install-Module MSOnline
        Connect-MsolService
    }
    else{
        Write-Host "Debe ejecutarse como administrador" -BackgroundColor Black -ForegroundColor Red
        Start-Sleep -Seconds 3
        Return
    }

}
catch {
    #logs
    Throw{ (Write-Warning -Message "La ou no puede ser procesada, proporcione un Distinguished Name valido por Ej. OU=Servers,DC=secure-demos,DC=algeiba,DC=com")
    }
}

try {
    switch ($Mode) {
        "ReportOnly" {
            Write-Host "Inicio de actividades ReportOnly"
            "Inicio de actividades ReportOnly" | Out-File -Encoding utf8 -FilePath $logPath -Append
            $users = Get-MsolUser -All
            $MFA = @()
            ForEach ($user in $users) {

                $MFA = New-Object System.Object

                ForEach ($sta in $user.StrongAuthenticationMethods){

                    $MFA | Add-Member -type NoteProperty -name DisplayName -Value  $user.DisplayName
                    $MFA | Add-Member -type NoteProperty -name UserPrincipalName -Value $user.UserPrincipalName
                    $MFA | Add-Member -type NoteProperty -name AuthenticationMethods -Value $user.StrongAuthenticationMethods.MethodType
                    $MFA | Add-Member -type NoteProperty -name Status -Value $user.StrongAuthenticationMethods.IsDefault
                }

                if ($user.StrongAuthenticationMethods -eq "") {
                    $MFA | Add-Member -type NoteProperty -name DisplayName -Value  $user.DisplayName
                    $MFA | Add-Member -type NoteProperty -name UserPrincipalName -Value $user.UserPrincipalName
                    $MFA | Add-Member -type NoteProperty -name AuthenticationMethods "None"
                    $MFA | Add-Member -type NoteProperty -name Status -Value "Disable"
                }

                $MFA += $MFA
            }
            $MFA | Export-CSV $ReportPath -NoTypeInformation -Append
        }
        "EnableMFA" {
            # Formato "bsimon@contoso.com","jsmith@contoso.com","ljacobson@contoso.com"
            $Users = Get-Content -Path $ImportPath

            foreach ($User in $Users)
            {
                $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
                $st.RelyingParty = "*"
                $st.State = "Enabled"
                $sta = @($st)
                Set-MsolUser -UserPrincipalName $user -StrongAuthenticationRequirements $sta 
            }
          }
        "DisableMFA" { 
            #Disable
            Get-MsolUser -UserPrincipalName $UPN | Set-MsolUser -StrongAuthenticationRequirements @()
         }
        Default {}
    }
    
}
catch {
    Write-Host "Ha ocurrido un error"
            "Ha ocurrido un error" | Out-File -Encoding utf8 -FilePath $logPath -Append
            Throw{ (Write-Warning -Message "Mensaje generico")
    }
}



