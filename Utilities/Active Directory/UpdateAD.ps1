

Import-Module ActiveDirectory

#Initialize Variables
$Names = Import-Csv -Path "$PSScriptRoot\adcorrections.csv" 


ForEach ( $person in $Names ){
    $username = $person.Username
    $title    = $person.Title
    $number   = $person.Phone
    $department = $person.Department 

    Set-ADUser -Identity $username `
               -Title $title `
               -OfficePhone $number `
               -Department $department
}