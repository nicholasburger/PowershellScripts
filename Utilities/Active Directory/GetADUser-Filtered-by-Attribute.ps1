Import-Module ActiveDirectory

Get-ADUser -Filter{extensionAttribute3 -Like "customattributeproperty"} -Properties extensionAttribute3 | Select-Object Name | Export-Csv ".\Attribute.csv"