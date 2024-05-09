<#####################################################################################################

    Filename: converttosharedmailbox.ps1

    Author: Nicholas Burger
    
        

####################################################################################################>



param (
    #Remove Username
    [Parameter(Mandatory=$true)]
    [String]$Username,

    [Parameter(Mandatory=$false)]
    [string]$Forwardemailuser
)

Import-Module ActiveDirectory
Import-Module ExchangeOnlineManagement

$LocalCredential = Get-Credential #Import-Clixml -Path "$PSScriptRoot\..\..\Libraries\Credentials\localcred.xml"
$CloudCredential = Get-Credential #Import-Clixml -Path "$PSScriptRoot\..\..\Libraries\Credentials\cloudcred.xml"

#Connect to Exchange Online
Connect-ExchangeOnline -Credential $CloudCredential

$RemoveUser = Get-ADUser -Identity $Username
$Forwardmail = (Get-ADUser -Identity $Forwardemailuser).PrimarySMTPAddress

$mailboxname = $RemoveUser.UserPrincipalName


#Change Mailbox to Shared
Set-Mailbox -Identity $mailboxname -Type Shared -ForwardingAddress $Forwardmail

Disconnect-ExchangeOnline

#check for contacts containing the name and remove them.
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://BI-MSMESCA.brightco.com/PowerShell" -Authentication Kerberos -Credential $LocalCredential
$ContactName = $RemoveUser.DisplayName


Import-PSSession -Session $Session -DisableNameChecking


    Set-Mailbox -Identity $mailboxname -HiddenFromAddressListsEnabled $true

    Get-Contact -Anr "$ContactName*" | Remove-MailContact


Remove-PSSession $Session