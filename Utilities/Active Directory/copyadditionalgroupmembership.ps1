Import-Module ActiveDirectory

$User1 = Get-ADPrincipalGroupMembership -Identity user1


$User2 = Get-ADPrincipalGroupMembership -Identity user2


foreach ( $group in $User1 ) {
    
    if ( $User2 -notcontains $group ){
        Add-ADGroupMember -Identity $group -Members user2
        Write-Host "Group Added: $group"
    }
}