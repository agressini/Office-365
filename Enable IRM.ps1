$cred = get-credential
$session = new-pssession -configurationname microsoft.exchange -connectionuri https://ps.outlook.com/powershell/ -credential $cred -authentication basic –allowredirection
Import-pssession $session
Get-irmconfiguration
#Este commando debe devolver un valor true
#De lo contrario debemos ejecutar:
#Azurermslicensingenabled value: if false execute set-irmconfiguration -azurermslicensingenabled $true
Test-irmconfiguration -sender admin@M365x218777.onmicrosoft.com
