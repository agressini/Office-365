param (
    [Parameter(Mandatory=$true,Position=0)]
    [ValidateSet("EnableTrial","CleanTrial")]
    [string]$Mode,

    [Parameter(Mandatory=$false,Position=1)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ImportFile
    )

#Variables basicas    
Import-Module -Name MSonline -ErrorAction SilentlyContinue
Import-Module -Name ActiveDirectory -ErrorAction SilentlyContinue
Write-Host "Seting up Variables..." -ForegroundColor Yellow
$ExportPath = "$env:USERPROFILE\Downloads\"
$logPath = ($ExportPath + "MFA_OPS-log.txt")
$ModuleMSOL = Get-Module -Name MSOnline -ErrorAction SilentlyContinue
$ModuleAD = Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

#print de los valores
Write-Host "La actividad sera reflejada en: $logPath" 
"La actividad sera reflejada en: $logPath" | Out-File -Encoding utf8 -FilePath $logPath -Append
#agregar al log Version del modulo

try {
        
    If ($ModuleMSOL)
    {
        Write-Host "Conectando a MS Online: "
        "Conectando a MS Online!" | Out-File -Encoding utf8 -FilePath $logPath -Append
        Connect-MsolService
    }   
    elseif (!$ModuleMSOL -and $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
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
        
    If ($ModuleAD)
    {
        Write-Host "Modulo de AD Cargado: "
        "Modulo de AD Cargado" | Out-File -Encoding utf8 -FilePath $logPath -Append
    }   
    elseif (!$ModuleAD -and $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Install-Module ActiveDirectory
    }
    else{
        Write-Host "Debe ejecutarse como administrador" -BackgroundColor Black -ForegroundColor Red
        Start-Sleep -Seconds 3
        Return
    }

}
catch {
    Write-Host "Error: al conectarse con Active Directory"
    "Error: al conectarse con Active Directory"| Out-File -Encoding utf8 -FilePath $logPath -Append
}

try {
    switch ($Mode) {
        "EnableTrial" {
            $UsersF3 = Get-ADGroupMember -Identity "Office 365 F3"
            foreach ($UserF3 in $UsersF3)
            {
                $state = Get-MsolUser -UserPrincipalName (Get-ADuser $UserF3).UserPrincipalName

                if(!$state.StrongAuthenticationMethods){
                    Add-ADGroupMember -Identity Office "365 P1 Trial" -Members $UserF3.SamAccountName
                    Write-Host  $UserF3.SamAccountName " El usuario fue agregado al grupo con licencias Azure AD P1"
                    $UserF3.SamAccountName + " El usuario fue agregado al grupo con licencias Azure AD P1" | Out-File -Encoding utf8 -FilePath $logPath -Append
                }
                else {
                    Write-Host  $UserF3.SamAccountName " ya posee un metodo de autenticacion"
                    $UserF3.SamAccountName + " ya posee un metodo de autenticacion" | Out-File -Encoding utf8 -FilePath $logPath -Append
                }
            }    
          }
         "CleanTrial" {
            $UsersF3 = Get-ADGroupMember -Identity "Office 365 F3"
            foreach ($UserF3 in $UsersF3)
            {
                $state = Get-MsolUser -UserPrincipalName (Get-ADuser $UserE1).UserPrincipalName

                if($state.StrongAuthenticationMethods){
                    Remove-ADGroupMember -Identity Office "365 P1 Trial" -Members $UserF3.SamAccountName
                    Write-Host  $UserF3.SamAccountName " El usuario fue removido al grupo con licencias Azure AD P1"
                    $UserF3.SamAccountName + " El usuario fue removido al grupo con licencias Azure AD P1" | Out-File -Encoding utf8 -FilePath $logPath -Append
                }
            }
          }
        Default {}
    }
    
}
catch {
    Write-Host "Ha ocurrido un error durente el proceso de configuracion"
    "Ha ocurrido un error durente el proceso de configuracion" | Out-File -Encoding utf8 -FilePath $logPath -Append
}



