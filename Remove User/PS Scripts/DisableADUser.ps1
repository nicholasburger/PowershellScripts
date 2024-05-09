<##################################################################################################################################

    Filename: DisableADUser.ps1

    Author: Nicholas Burger


    

##################################################################################################################################>


param (
    #Remove Username
    [Parameter(Mandatory=$true)]
    [String]$Username
)


Import-Module ActiveDirectory
Import-Module "$PSScriptRoot\..\..\Libraries\SetMFA.psm1"

[string] $Description = ""
[string] $Rename = ""
$credential = Get-Credential # Import-Clixml -Path "$PSScriptRoot\..\..\Libraries\Credentials\cloudcred.xml"

#Get remove user object from AD
$RemoveUser = Get-ADUser $Username

#Get groups to remove from user to free up licenses and the groups that the user contains
$GroupsToRemove = Get-ADGroup -Filter "Name -like 'Azure*' -or Name -like 'Adobe*'"
$UserGroups =  Get-ADPrincipalGroupMembership -Identity $RemoveUser

#Write the company to the output
$Company = ( ($RemoveUser.DistinguishedName) -split ',' )[1]
$Output = $Company.Replace("OU=","")

$Output = $Output + ',' + ( $RemoveUser.UserPrincipalName )

Write-Output $Output

#Set Description with Term and the date
$Date = Get-Date -Format "MM/dd/yy"
$Description = "Term - $Date"

#Set Object name to include a Z. at the begining of the name
$Rename = "Z." + $RemoveUser.Name


ForEach ( $Group in $GroupsToRemove ) {
    
    if ( $Group -contains $UserGroups ){

        Remove-ADGroupMember -Identity $Group -Members $RemoveUser

    }
}



Set-ADUser -Identity $RemoveUser `
    -Description $Description `
    -Enabled $false

Rename-ADObject -Identity $RemoveUser -NewName $Rename

Connect-MsolService -Credential $credential

Get-MSOLUser -UserPrincipalName $RemoveUser.UserPrincipalName | Set-MFAState -UserPrincipalName $RemoveUser.UserPrincipalName -State Disabled
