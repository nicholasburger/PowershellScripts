<#############################################################################################################

    FileName: HorizonViewFunct.psm1

    Author: Nick Burger

    Version: 0.1

    Usage:
        Include in scripts with...
        Import-Module <Location>\HorizonViewFunct.psm1

##############################################################################################################>

Import-Module VMware.VimAutomation.HorizonView
Import-Module VMware.VimAutomation.Core

function Find-SessionID {
    param (
        # AD User
        [Parameter(Mandatory=$true)]
        [string]
        $User,

        # Horizon Server
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [VMware.VimAutomation.HorizonView.Impl.V1.ViewServerImpl]
        $HorizonServer
    )

<#
.SYNOPSIS

Return Session of username connected to Horizon Server

.DESCRIPTION

Returns the Session ID of the username passed into the function that is connected to the Horizon Server also passed
into the fuction.  Must pass String as username and VMware.VimAutomation.HorizonView.Impl.V1.ViewServerImpl as Horizon Server

.PARAMETER User
System.String
Must be the AD DS username that is used for logging into the Horizon View application.

.PARAMETER HorizonServer
VMware.VimAutomation.HorizonView.Impl.V1.ViewServerImpl
The Horizon Server variable that is created with a Connect-HVServer command. 

.OUTPUTS

Session ID
System.String
This is the ID that the Horizon Server uses to represent the connected session of the user

.EXAMPLE

$Credential = Get-Credential
$HVServer = Connect-HVServer -Server "vdi.horizonservername.com" -Credentials Credential

$SessionID = Find-SessionID -User $User -HorizonServer $HVServer


#>

    $query = New-Object "Vmware.Hv.QueryDefinition"
    $query.queryEntityType = 'SessionLocalSummaryView'
    $qSrv = New-Object "Vmware.Hv.QueryServiceService"
    $Results = ( $qSRv.QueryService_Query( $HorizonServer.ExtensionData , $query ) ).Results
    
    ForEach ( $Item in $Results) {

        $SessionUser = $Item.NamesData.Username
        $SessionID = $Item.Id

        If ( $SessionUser -eq $User ) {
            
            return $SessionID

        }

    }

}


function Get-SessionVMName {
    param (
        # Session ID
        [Parameter(Mandatory=$true)]
        [VMware.Hv.SessionId]
        $Session,

        # Horizon Server
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [VMware.VimAutomation.HorizonView.Impl.V1.ViewServerImpl]
        $HorizonServer
        
    )

    <#
    .SYNOPSIS
    Returns name of the VM the session ID is associated with

    .DESCRIPTION
    When passed a Session ID of a Horizon View VM it will find the Machine name of said VM.

    .Parameter Session
    Pass the Session ID of the VM from the Horizon Server.

    .Parameter HorizonServer
    Pass the Horizon Server object from Connect-HVServer command.

    .OUTPUTS
    [System.String]
    VM name
    Outputs string with the name of the NETBIOS name of the VM.
    
    #>

    $query = New-Object "Vmware.Hv.QueryDefinition"
    $query.queryEntityType = 'SessionLocalSummaryView'
    $qSrv = New-Object "Vmware.Hv.QueryServiceService"
    $Results = ( $qSRv.QueryService_Query( $HorizonServer.ExtensionData , $query ) ).Results
    
    ForEach ( $Item in $Results) {

        $VMName = $Item.NamesData.MachineOrRDSServerName
        $SessionID = $Item.Id

        If ( $SessionID -like $Session ) {
            
            return $VMName

        }

    }
    
}


function Get-VMIP {
    param (
        # Name of VM
        [Parameter(Mandatory=$true,ValueFromPipeline)]
        [string]
        $VMName,

        # vSphere server object
        [Parameter(Mandatory=$true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer]
        $VCenter
    )

    <#
    .SYNOPSIS
    Gets the IP address of VM in vCenter

    .PARAMETER VMName
    String with the name of VM.

    .PARAMETER VCenter
    [VMware.VimAutomation.ViCore.Types.V1.VIServer]
    vCenter Server object created from Connect-VIServer command.

    .OUTPUTS
    [System.String]
    IPv4 address of VM.

    #>
    
    $VM = Get-VM -Name $VMName

    $Ip = $VM.ExtensionData.Guest.Net.IpAddress

    return $Ip

}

function Get-VMName {
    param (
        # Name of VM
        [Parameter(Mandatory=$true,ValueFromPipeline)]
        [string]
        $IPAddress,

        # vSphere server object
        [Parameter(Mandatory=$true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer]
        $VCenter
    )
   
    [string]$VMName = ""

    $VMs = Get-VM -Server $VCenter

    ForEach ( $VM in $VMs ){
        
        $VMIP = $VM.ExtensionData.Guest.Net.IpAddress

        If ( $VMIP -eq $IPAddress ){

           $VMName = $VM.Name
        }
    }

    return $VMName

}



function Disconnect-VMSession {
    param (
        # User to disconnect
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Username,

        # Horizon Server
        [Parameter(Mandatory=$true)]
        [VMware.VimAutomation.HorizonView.Impl.V1.ViewServerImpl]
        $HorizonServer,

        # vCenter Server
        [Parameter(Mandatory=$false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer]
        $VCenterServer,

        # Switch - Return IP
        [Parameter(Mandatory=$false)]
        [switch]
        $IP
    )

    $SessionID = Find-SessionID -User $Username -HorizonServer $HorizonServer

    $VMName = Get-SessionVMName -Session $SessionID -HorizonServer $HorizonServer

    $HorizonServer.ExtensionData.Session.Session_Disconnect( $SessionID )

    If ( $IP ){
        return Get-VMIP -VMName $VMName -VCenter $VCenterServer
    }

}

function Restart-VMbyIP {
    param (
        # IP Address
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $IPAddress,

        # vCenter Server
        [Parameter(Mandatory=$false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer]
        $VCenterServer
    )

    [string]$VMName = ""

    $VMName = Get-VMName -IPAddress $IPAddress -VCenter $VCenterServer

    Restart-VM -VM $VMName -Server $VCenterServer -RunAsync
    
}


function Remove-VMSession {
    param (
        # User to disconnect
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Username,

        # Horizon Server
        [Parameter(Mandatory=$true)]
        [VMware.VimAutomation.HorizonView.Impl.V1.ViewServerImpl]
        $HorizonServer,

        # vCenter Server
        [Parameter(Mandatory=$false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer]
        $VCenterServer

    )

    $SessionID = Find-SessionID -User $Username -HorizonServer $HorizonServer

    $HorizonServer.ExtensionData.Session.Session_LogoffForced( $SessionID )
}
