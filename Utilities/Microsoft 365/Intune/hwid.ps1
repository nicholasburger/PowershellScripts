<#
.SYNOPSIS
Creates or Appends to CSV for uploading into Intune for Autopilot

.DESCRIPTION
    When run from a computer as an administrator, this script will install the Get-WindowsAutopilotInfo command
and then run the command outputing the results to a CSV in the same location that the script is being executed from.
If you wish to update the location the CSV outputs please update the location to another update the -OutputFile
section of the Get-WindowsAutopilotInfo command.  

    A common way to use this script is from a USB Thumb drive so that the CSV continues to be added to between 
computers.  Once run on all devices you can then take the CSV file and upload it to enroll the affected devices
into Windows Autopilot from the Microsoft Intune portal.

.EXAMPLE
PS> .\hwid.ps1

.INPUTS
None

.OUTPUTS
CSV file at the specificed location.  Name "AutopilotHWID.csv"
Default is same folder as script
#>

<#
$interface = Get-NetIPConfiguration | Where-Object { ($_.InterfaceAlias -like "*Ethernet*") -or ($_.InterfaceAlias -like "*Local*" ) } | Select-Object -Property InterfaceIndex

Set-DnsClientServerAddress -InterfaceIndex $interface.InterfaceIndex -ServerAddresses 8.8.8.8
#>
#New-Item -Type Directory -Path "C:\HWID"
Set-Location $PSScriptRoot
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
Install-Script -Name Get-WindowsAutopilotInfo -Force
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Get-WindowsAutopilotInfo -OutputFile ".\AutopilotHWID.csv" -Append

#Set-DnsClientServerAddress -InterfaceIndex $interface.InterfaceIndex -ServerAddresses <insert dns addresses separated by comma>