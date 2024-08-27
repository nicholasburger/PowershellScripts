<####################################################################################################
    Name: gporemoval.ps1

    .DESCRIPTION
        Takes GPOs from a csv, backs them up to indicated file and then removes the GPOs

    .EXAMPLE
        .\gporemoval.ps1 -CSV ".\gpos.csv" -BackupLocation ".\Backup Folder" -Remove

        This command will remove the GPOs after backing them up

    .EXAMPLE
        .\gporemoval.ps1 -CSV ".\gpos.csv" -BackupLocation ".\Backup Folder"

        This command will only backup the GPOs but won't remove them.

    .EXAMPLE
        .\gporemoval.ps1 -CSV ".\gpos.csv" -Remove

        This command will remove the GPOs without backing them up

    .PARAMETER CSV
        Type: STRING

        This is the location and name of the csv file.

    .PARAMETER BackupLocation
        Type: STRING

        This is the folder where you want the GPO backups to be stored.

    .PARAMETER Remove
        Type: SWITCH

        This paramater allow for the removal of the GPOs


######################################################################################################>



param (
    # CSV File
    [Parameter(Mandatory=$true)]
    [string]
    $CSV,

    # Output files for backups
    [Parameter()]
    [string]
    $BackupLocation,

    # Remove as well
    [switch]
    $Remove = $false
)


# Module Import
Import-Module GroupPolicy

# Variable Initialization

[bool]$continue = $true
[bool]$Backup = !( $null -eq $BackupLocation )

$GPONames = $null
$GPOs = $null


###################################################################################
# 1.0 - Get CSV File
###################################################################################

try {

    if ( Test-Path $CSV ) {
        $GPONames = Import-Csv -Path $CSV
    } else {
        Write-Error "File doesn't exist please check filename or path.`n$CSV"
    }
}
catch {
    Write-Output "Error with file.`n"
    Write-Debug $_.ErrorDetails.Message
    $continue=$false
}


###################################################################################
# 1.1 - Get GPO objects
##################################################################################
if ( $continue ) {
    try {
        if ( $null -eq $GPONames.Name ) {
            Write-Error "CSV File doesn't have a Name column.  Check file format.`n$CSV"
        }

        $GPOs = $GPONames.Name | Get-GPO
    }
    catch {
        Write-Output "Error getting GPO objects`n"
        Write-Debug $_.ErrorDetails.Message
        $continue = $false
    }
}


#################################################################################
# 1.2 - Backup GPOs
#################################################################################

if ( $continue -and $Backup ) {
    try {
        if ( ! ( Test-Path $BackupLocation ) ) {
            Write-Error "Problem with Bakcup Location. Please check location.`n$BackupLocation"
        }
        
        $GPOs | Backup-GPO -Path $BackupLocation -Comment "Backup as part of CR:Remove Unlinked GPOs" | Export-Csv -Path "$BackupLocation\gpobackupinfo.csv" -NoTypeInformation
    }
    catch {
        Write-Output "Error Backing up GPOs"
        Write-Debug $_.ErrorDetails.Message
        $continue = $false
    }
}


##################################################################################
# 1.3 - Remove GPOs
##################################################################################

if ( $continue -and $Remove ) {
    try {
        $GPOs | Remove-GPO
    }
    catch {
        Write-Output "Error removing GPOs.`n"
        Write-Debug $_.ErrorDetails.Message
    }
}