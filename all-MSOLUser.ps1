Connect-MsolService
Get-MsolUser -All  | select DisplayName,UserPrincipalName,City,Country,Department,IsLicensed,LastDirSyncTime,LastPasswordChangeTimestamp,Office,State,StreetAddressStsRefreshTokensValidFrom,Title,UsageLocation,serType,ValidationStatus | Export-Csv -Path .\users.csv -notypeinformation -Encoding UTF8
