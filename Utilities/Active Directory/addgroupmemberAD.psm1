Import-Module ActiveDirectory


function Set-GroupMembership {

param ([String[]] $Oldgroups,[String[]] $Newgroups )


$Members = Get-ADGroupMember -Identity $Oldgroups

$FQGroupName = Get-ADGroup -Identity $Newgroups

Add-ADGroupMember -Identity $FQGroupName -Member $Members

}