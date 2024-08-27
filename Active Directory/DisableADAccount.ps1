<###############################################################################################################################

    Name: DisableADAccount

    .SYNOPSIS
        Takes a CSV and disables accounts by UPN
    
    .DESCRIPTION
        Locate a file to a CSV document that has a column named UserPrincipalName containing the UPNs of the accounts that need
        to be deleted.

    .PARAMETER CSV
        Location of the CSV file 


#################################################################################################################################>


param (
    [Parameter(Mandatory=$true)]
    [string]
    $CSV
)

# Modules
Import-Module ActiveDirectory

# Variables
$UserList = $null
[string]$Description = ""
[datetime]$Date = Get-Date -Format "mm/dd/yyyy"
[bool]$continue = $true


##################################################################
#  1.0 - Import CSV file
##################################################################

try {
    if ( Test-Path $CSV ) {
        $UserList = $(Import-Csv -Path $CSV).UserPrincipalName
    } else {
        Write-Error "Could not find Path: $CSV"
    }
}
catch {
    Write-Output "Error with file.`n"
    Write-Debug $_.ErrorDetails.Message
    $continue = $false
}


##################################################################
# 1.1 - Get the AD accounts
##################################################################

if ( $continue ) {
      try {
        $Accounts = $UserList | Get-ADUser
      }
      catch {
        Write-Output "Error getting AD accounts.`n"
        Write-Debug $_.ErrorDetails.Message
        $continue = $false
      } 
}


##################################################################
# 1.2 - Disable Accounts
##################################################################

if ( $continue ) {
    try {
        foreach ( $account in $Accounts){
            $Description = $account.Description + "-Disabled by CR for TERM in Name on $Date"
            Set-ADUser -Enabled $false -Description $Description
        }
    }
    catch {
        Write-Output "Error disabling accounts.`n"
        Write-Debug $_.ErrorDetails.Message
    }
}