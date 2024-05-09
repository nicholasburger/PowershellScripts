<###########################################################################################

    Filename: DisconnectSession.ps1

    Author: Nick Burger

    For use by Bright Industries

    Version 0.1

    Usage: Designed to be used by Microsoft Power Automate - Remove User Flow.

        For parameters...

        -Username - Include username without any brightco\ or @brightco.com or any other identifier.  Username should match
                    the SamAccountName parameter of an ADUser object

        -HorizonServerName - String input matching the FQDN name of the Horizon server you want to check against.

        -VCenterServerName - String input matching the FQDN name of the vCenter Server that services the Horizon environment cluster

        -BackupLocation - Sring input matching the FQDN and folder location for backing up the user's profile prior to logging off the VM

        Call using...

        .\DisconnectSession.ps1 -Username <username> -HorizonServerName <Connection Server Name> -VCenterServerName <vCenter Server Name>

############################################################################################>

param (

    # Username of User to disconnect
    [Parameter(Mandatory=$true)]
    [string]
    $Username,

    # Horizon Server Name
    [Parameter(Mandatory=$true)]
    [string]
    $HorizonServerName,

    # VCenter Server Name
    [Parameter(Mandatory=$true)]
    [string]
    $VCenterServerName,

    # Backup location
    [Parameter(Mandatory=$true)]
    [string]
    $BackupLocation

)


Import-Module "$PSScriptRoot\..\..\Libraries\HorizonViewFunct.psm1"

$User = "domain.com\$Username"

$credential = Import-Clixml -Path "$PSScriptRoot\..\..\Libraries\Credentials\localcred.xml"


$HorizonServer = Connect-HVServer -Server $HorizonServerName -Credential $credential

$VCenterServer = Connect-VIServer -Server $VCenterServerName -Credential $credential


$IPAddress = Disconnect-VMSession -User $User -HorizonServer $HorizonServer -VCenterServer $VCenterServer -IP


Write-Output $IPAddress


$VMUserProfileLocation = "\\$IPAddress\c$\Users\$Username"


Copy-Item -Path "$VMUserProfileLocation\Desktop", `
                "$VMUserProfileLocation\Downloads", `
                "$VMUserProfileLocation\Documents", `
                "$VMUserProfileLocation\Pictures", `
                "$VMUserProfileLocation\Videos" `
            -Destination "$BackupLocation\$Username\" `
            -Recurse

Restart-VMbyIP -IPAddress $IPAddress -Server $VCenterServer

Disconnect-HVServer -Server $HorizonServer -Confirm:$false
Disconnect-VIServer -Server $VCenterServer -Confirm:$false
