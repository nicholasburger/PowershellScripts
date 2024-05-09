<########################################################################################################

    FileName: emailsetup.ps1

    Author: Nicholas Burger

    Version: 0.1

    

#########################################################################################################>

#Parameters Section

param (

# Username
[Parameter(Mandatory=$true)]
[string]
$Username
)
Import-Module ActiveDirectory
Import-Module ExchangeOnlineManagement

#[String]$Mailbox = ""
$credential = Get-Credential #Import-Clixml -Path "..\..\Libraries\Credentials\localcred.xml"
$user = Get-ADUser $Username
$routing = $user.samaccountname + "@domain.mail.onmicrosoft.com"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://exchangeserver.domain.com/PowerShell" -Authentication Kerberos -Credential $credential


Import-PSSession -Session $Session -DisableNameChecking

    
    Enable-RemoteMailbox $user.SamAccountName -Alias $user.SamAccountName -RemoteRoutingAddress $routing

Remove-PSSession $Session