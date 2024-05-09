
param (
    
    #Folder Path to check
    [Parameter(Mandatory=$true)]
    [string]$path,

    # outfile path and name
    [Parameter(Mandatory=$false)]
    [string]
    $Outfile
)

$Folders = Get-ChildItem -Path $path -Recurse -Directory

ForEach ( $Folder in $Folders ) { 
    $Acl = Get-Acl -Path $Folder.FullName 
    
    ForEach ($Access in $Acl.Access) { 
    
        $Properties = [ordered]@{'Folder Name' = $Folder.FullName; `
        'Group/User' = $Access.IdentityReference; `
        'Permissions'=$Access.FileSystemRights; `
        'Inherited'=$Access.IsInherited} 
    
        if ( $Outfile -ne "" ){
            New-Object -TypeName PSObject -Property $Properties | Export-Csv -Path $Outfile -Append

        } 
            $Output = New-Object -TypeName PSObject -Property $Properties
        
        
        Write-Host = $Output

    } 
}



<#
$arrayitems = @{}

#[int]$count = 1
#Out-Host -InputObject $arrayitems

$folders = Get-ChildItem -Path $path -Recurse -directory


foreach ( $item in $folders ) 
{ 

$access = (get-acl -Path $item.FullName).access | Format-Table IdentityReference,AccessControl,FileSystemAccessRule

$arrayitems =  @{ "Directory"= $item.FullName; `
                    "Permissions" = $access
                }

if ( $Outfile -ne "" ){

    #Export-Csv -Path $Outfile -InputObject $arrayitems -Append -Force
} 

Out-Host -InputObject $access
                
#$count = $count + 1
} 
#>