<#########################################################################################################

    Filename: warningquotaset.ps1

    Version: 0.1

    Author: Nick Burger

    Usage: warningquotaset.ps1 -Email <useremailaddress>

    Example:

        .\warningquotaset.ps1 -Email Testy.McTestface@billc.com


###########################################################################################################>

param (

    # Email address of the user to test on.
    [Parameter(Mandatory=$true)]
    [string]
    $Email

)

$credential = Get-Credential #Import-Clixml -Path "..\..\Libraries\Credentials\cloudcred.xml"

Connect-ExchangeOnline -Credential $credential

Set-Mailbox -Identity $Email -IssueWarningQuota 70GB



Disconnect-ExchangeOnline -Confirm:$false