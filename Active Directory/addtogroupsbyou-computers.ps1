Import-Module ActiveDirectory


$csv = Import-Csv -Path ".\SMB Properties.csv"

$Phases = @( "Testing","Phase 1","Phase 2","Phase 3","Phase 4","Phase 5")
$Groups = @("Change Pilot","Change Phase 1", "Change Phase 2","Change Phase 3","Change Phase 4","Change Phase 5")

$AllOUs = Get-ADOrganizationalUnit -Filter *



for ($i = 0; $i -lt $Phases.Count, $i++ ){
    $Properties = ($csv | Where-Object { $_.Phase -eq $Phases[$i] } ).PropertyCode 

    $OUList = $AllOUs | Where-Object { $Properties -contains $_.Name }

    $Computers = ( $OUList | ForEach-Object -Process { Get-ADComputer -Filter * -SearchBase $_ } ) 

    $GroupObject = New-ADGroup -Name $Groups[$i] -GroupCategory "Security" -GroupScope "Global" -Path "OU=SECURITY GROUPS,DC=omnihotels,DC=net"

    Add-ADGroupMember -Identity $GroupObject -Members $Computers
}


