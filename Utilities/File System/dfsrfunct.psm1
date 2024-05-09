#Create a DFSR replication group
Import-Module DFSR


function Set-DFSR {

param ([String] $replicationGroupName, [String] $FolderName, [String] $ContentPath, [String] $MemberPath, [String] $PrimaryHost,[String[]] $Members )


New-DFSReplicatedFolder -GroupName $replicationGroupName `
    -FolderName $FolderName | Out-Null

Set-DFSRMembership -GroupName $replicationGroupName `
    -ComputerName $PrimaryHost `
    -FolderName $FolderName `
    -ContentPath $ContentPath `
    -ReadOnly $false `
    -PrimaryMember $true `
    -Force | Out-Null  

Set-DFSRMembership -GroupName $replicationGroupName `
    -ComputerName $Members `
    -FolderName $FolderName `
    -ContentPath $MemberPath `
    -ReadOnly $true `
    -Force | Out-Null
}


