<#################################################################################

    FILENAME: findVMIP.ps1

    AUTHOR: Nick Burger

    USAGE: This will pull the IP of connected username and restart the VM
    
    UPDATE LOG:
    DATE     VERSION     NOTES
    6/16/23  0.1         File creation

##################################################################################>

#Section 0.1 - Parameter Block
param (
    [Parameter(Mandatory=$true)]
    [string]
    $UserName
)


#Section 0.2 - Module Reference
Import-Module "..\..\Libraries\HorizonViewFunct.psm1"


#Section 0.3 - Variable Initialization
[VMware.VimAutomation.HorizonView.Impl.V1.ViewServerImpl]$HorizonServer = $null
$User = "domain.com\$Username"
$credential = Get-Credential #Import-Clixml -Path "$PSScriptRoot\..\..\Libraries\Credentials\localcred.xml"
[string]$HorizonServerName = "uag.brightco.com"
[string]$VCenterServerName = "bi-vcenter-1.brightco.com"

#Section 1.0 - connect to Horizon Server and vCenter Servers
$HorizonServer = Connect-HVServer -Server $HorizonServerName -Credential $credential
$VCenterServer = Connect-VIServer -Server $VCenterServerName -Credential $credential

#Section 2.0 - Log off VM
Remove-VMSession -Username $User -HorizonServer $HorizonServer -VCenterServer $VCenterServer
