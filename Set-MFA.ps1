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

#Variables basicas    
Import-Module -Name MSonline -ErrorAction SilentlyContinue
Write-Host "Seting up Variables..." -ForegroundColor Yellow
$Now = Get-Date
$ExportPath = "$env:USERPROFILE\Downloads\"
$logPath = ($ExportPath + "MFA_OPS-log.txt")
$ReportPath = $ExportPath + "Report_MFA_USERS" +($Now).ToString("yyMMddhhmm") + ".csv"
$Module = Get-Module -Name MSOnline -ErrorAction SilentlyContinue
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

#print de los valores
Write-Host "La actividad sera reflejada en: $logPath" 
"La actividad sera reflejada en: $logPath" | Out-File -Encoding utf8 -FilePath $logPath -Append
#agregar al log Version del modulo

try {
        
    If ($Module)
    {
        Write-Host "Conectando a MS Online: "
        "Conectando a MS Online!" | Out-File -Encoding utf8 -FilePath $logPath -Append
        Connect-MsolService
    }   
    elseif (!$Module -and $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
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
    Write-Host "Error: al conectarse con Office 365"
    "Error: al conectarse con Office 365"| Out-File -Encoding utf8 -FilePath $logPath -Append
}

try {
    switch ($Mode) {
        "ReportOnly" {
            Write-Host "Inicio de actividades ReportOnly"
            "Inicio de actividades ReportOnly" | Out-File -Encoding utf8 -FilePath $logPath -Append
            $users = Get-MsolUser -All
            $MFAtotal = @()
            ForEach ($user in $users) {

                if (!$user.StrongAuthenticationMethods) {
                    $noMFA = New-Object System.Object
                    $noMFA | Add-Member -type NoteProperty -name DisplayName -Value  $user.DisplayName
                    $noMFA | Add-Member -type NoteProperty -name UserPrincipalName -Value $user.UserPrincipalName
                    $noMFA | Add-Member -type NoteProperty -name AuthenticationMethods "None"
                    $noMFA | Add-Member -type NoteProperty -name Status -Value "Disable"
                    $MFAtotal += $noMFA
                    Write-Host "MFA no configurado: " + $user.UserPrincipalName
                    "MFA no configurado: " + $user.UserPrincipalName | Out-File -Encoding utf8 -FilePath $logPath -Append
                }
                else {
                    ForEach ($sta in $user.StrongAuthenticationMethods){
                        $MFA = New-Object System.Object
                        $MFA | Add-Member -type NoteProperty -name DisplayName -Value  $user.DisplayName
                        $MFA | Add-Member -type NoteProperty -name UserPrincipalName -Value $user.UserPrincipalName
                        $MFA | Add-Member -type NoteProperty -name AuthenticationMethods -Value $sta.MethodType
                        $MFA | Add-Member -type NoteProperty -name Status -Value $sta.IsDefault
                        $MFAtotal += $MFA
                        Write-Host "MFA configurado: " + $user.UserPrincipalName
                        "MFA configurado: " + $user.UserPrincipalName | Out-File -Encoding utf8 -FilePath $logPath -Append
                    }
                    
                }
            }
            $MFAtotal | Export-CSV $ReportPath -NoTypeInformation -Append
            Write-Host "Elreporte de usuarios esta disponible en: $ReportPath" 
            "Elreporte de usuarios esta disponible en: $ReportPath" | Out-File -Encoding utf8 -FilePath $logPath -Append
        }
        "EnableMFA" {
            # Formato "bsimon@contoso.com","jsmith@contoso.com","ljacobson@contoso.com"
            $Users = Import-Csv -Delimiter "," -Path $ImportFile
            
            foreach ($User in $Users)
            {
                $state = Get-MsolUser -UserPrincipalName $User.UserPrincipalName

                if(!$state.StrongAuthenticationMethods){
                    $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
                    $st.RelyingParty = "*"
                    $st.State = "Enabled"
                    $sta = @($st)

                    Set-MsolUser -UserPrincipalName $state.UserPrincipalName -StrongAuthenticationRequirements $sta 

                    Write-Host  $state.UserPrincipalName " ahora tiene activo un metodo de autenticacion"
                    $state.UserPrincipalName + " ahora tiene activo un metodo de autenticacion" | Out-File -Encoding utf8 -FilePath $logPath -Append
                }
                else {
                    Write-Host  $state.UserPrincipalName " ya posee un metodo de autenticacion"
                    $state.UserPrincipalName + " ya posee un metodo de autenticacion" | Out-File -Encoding utf8 -FilePath $logPath -Append

                }
            }
          }
        "DisableMFA" { 
            #Disable
            Get-MsolUser -UserPrincipalName $UPN | Set-MsolUser -StrongAuthenticationRequirements @()
            Write-Host "MFA deshabilitado: " + $UPN
            "MFA deshabilitado: " + $UPN | Out-File -Encoding utf8 -FilePath $logPath -Append
         }
        Default {}
    }
    
}
catch {
    Write-Host "Ha ocurrido un error durente el proceso de configuracion"
    "Ha ocurrido un error durente el proceso de configuracion" | Out-File -Encoding utf8 -FilePath $logPath -Append
}



