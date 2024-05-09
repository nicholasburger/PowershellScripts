<####################################################################################################

    Filename: ResetUserPassword.ps1

    Author: Nicholas Burger

    Description: Resets user's password and enables MFA for user

    Use: .\ResetUserPassword.ps1 -User <Username>


####################################################################################################>


Param (
    
    #Username to reset password
    [Parameter(Mandatory=$true)]
    [string]$User
)



Import-Module "$PSScriptRoot\..\..\Libraries\SetMFA.psm1"
Import-Module ActiveDirectory


$credential = Get-Credential #Import-Clixml -Path "$PSScriptRoot\..\..\Libraries\Credentials\cloudcred.xml"

#reset user's password
Set-ADUser -Identity $User -ChangePasswordAtLogon $true

$UserPrincipalName = (Get-ADUser -Identity $User).UserPrincipalName


#Set the MFA to enabled for the new user
Connect-MsolService -Credential $credential

Set-MFAState -ObjectID $User -UserPrincipalName $UserPrincipalName -State Enabled

Disconnect-MsolService