<#
Script for moving computers to Azure_Synced_Laptops OU

#>


[CmdletBinding()]
param (
    # CSV File
    [string]
    $CsvFile = ".\Documents\pilotgroup.csv",

    # OU to move to
    [string]
    $OUName = "Azure_Synced_Laptops"
)


# Module Imports

Import-Module ActiveDirectory


#Variables

$Computers = @()
$OU = $null
$CompNames = $null
[bool]$continue = $true 


# Test file location
try {
    if  ( Test-Path $CsvFile ){
        Write-Output "File not found"
        $continue = $false
    }
}
catch {
    Write-Debug "Error testing file location`n$($_.ErrorDetails.Message)"
    $continue = $false
}


# Grab OU
if ( $continue ) {
    try {
        $OU = Get-ADOrganizationalUnit -LDAPFilter "(name=$OUName)"
        
        if ( $null -eq $OU ){
            Write-Output "OU doesn't exist`nOU: $OUName"
            $continue = $false
        }
    }
    catch {
        Write-Debug "Error Grabbing OU Distinguished Name`n$($_.ErrorDetails.Message)"
        $continue = $false
    }
}

# Get Computer Objects from CSV

if ( $continue ) {
    try {
        $CompNames = Import-Csv -Path $CsvFile

        $Computers = $CompNames.ComputerName | Get-ADComputers 

    }
    catch {
        Write-Debug "Error getting computer objects.`n$($_.ErrorDetails.Message)"
        $continue = $false        
    }
}



# Complete the Move of the Computer Objects to new OU
if ( $continue ) {
    try {
        $Computers | Move-ADObject -TargetPath $OU.DistinguishedName
    }
    catch {
        Write-Debug "Error moving objects to new OU.`n$($_.ErrorDetails.Message)"
    }
}