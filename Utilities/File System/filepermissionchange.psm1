
function Set-Permission {
    param (
        [String] $Path, 
        [String] $UserGroup,
        [String] $Permission
    )

    <#
    
    .SYNOPSIS
    Set folder permissions

    .DESCRIPTION
    Pass location, group, and permission level to assign the permission in order to change
    the file permissions on said folder or file.  You must have administrator permissions
    and access to the folder location

    .PARAMETER Path
    Location of the folder you want to change.

    .PARAMETER UserGroup
    Group or user to assign permissions

    .PARAMETER Permission
    Permission said location should be given to said group.

    Permissions
    'Read'
    'ReadandExecute'
    'Write'
    'FullControl'

    .EXAMPLE

    Set-Permissions -Path '\\Fileserver\SharedFolder' -UserGroup 'Group1' -Permission 'Write'
    #>
    

    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ($UserGroup, $Permission,"ContainerInherit,ObjectInherit","None","Allow")

    $ACL = (Get-Item -Path  $Path).GetAccessControl('Access') #Get-Acl -Path $Path

    $ACL.SetAccessRule($AccessRule)

    $ACL | Set-Acl -Path $Path

    return (Get-Acl -Path $Path).Access

}