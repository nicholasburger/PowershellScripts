<########################################################################################################

    FileName: usercreation.ps1

    Author: Nicholas Burger

    Version: 0.1

    

#########################################################################################################>

#Parameters Section

param (
    #First Name
    [Parameter(Mandatory=$true)]
    [String]$FirstName,

    #Last Name
    [Parameter(Mandatory=$true)]
    [String]$LastName,

    # Username
    [Parameter(Mandatory=$true)]
    [string]
    $UserName,

    # OU
    [Parameter(Mandatory=$true)]
    [string]
    $Company,

    # Groups
    [Parameter(Mandatory=$false)]
    [String[]]
    $Groups,

    # Location
    [Parameter(Mandatory=$false)]
    [string[]]
    $Location,

    # Manager UserName
    [Parameter(Mandatory=$true)]
    [string]
    $Manager,

    # Location Info
    [Parameter(Mandatory=$true)]
    [String]
    $Title,

    # extensionAttributes
    [Parameter(Mandatory=$true)]
    [String[]]
    $CustomAttributes,

    # Phone Number
    [Parameter(Mandatory=$false)]
    [string]
    $Phone,

    # Logon Script
    [Parameter(Mandatory=$true)]
    [string]
    $ScriptPath
    
)

#End Parameter section

#Variable Initializaion section
Import-Module ActiveDirectory

[string]$homedirectory = ""
[string]$DisplayName = ""
$Password = ConvertTo-SecureString "Password1234" -Force -AsPlainText
[string]$PrincipalName = ""
$Manageruser = $null
[string]$OU = ""
[string]$email = ""
[string]$Street = ""
[string]$City = ""
[string]$State = ""
[string]$ZipCode = ""
[string]$Description = ""

#End Variable Initializaiton Section

#Set Variables for user creation section

#Set OU
$OU = "OU=$Company,DC=BRIGHTCO,DC=COM"

#set email suffix
switch ($Company) {
    
    "Bright Realty" { 
                        $email = "brightrealty.com" 
                        $Description = "RE $Title"
                    }

    "Bright Executive Services" { 
                                    $email = "billc.com" 
                                    $Description = "BES $Title"
                                }

    "American Legend Homes" { 
                                $email = "alhltd.com" 
                                $Description = "ALH $Title"
                            }

    "CHGC" { 
                $email = "thelakesch.com" 
                $Description = "CHGC $Title"
            }

    "BEITS" { 
                $email = "billc.com" 
                $Description = "BEITS $Title"
            }

    "Bright Equities" { 
                        $email = "brightequities.com" 
                        $Description = "BE $Title"
                    }

    "Bright Wealth Management" { 
                                    $email = "brightwealthmanagement.com" 
                                    $Description = "BWM $Title"
                                }

    "Infinity Lawnscape" { 
                            $email = "infinitylawnscap.com" 
                            $Description = "ILS $Title"
                        }
    "Discovery" {
                    $email = "discoveryattherealm.com"
                    $Description = "DISC $Title"
                }

    Default { 
                $email = "billc.com"
                $Description = "BI $Title"
             } 
}

#set location
$Street, $City, $State, $ZipCode = $Location


#Set Home directory
if ( $Company -eq "American Legend Homes") {

    $homedirectory = "\\alh-exshdr-02\users\$Username"

} elseif ( $Company -eq "Bright Equities" -or $Company -eq "Bright Wealth Managment" ){
    
    $homedirectory = "\\bi-fishdr-03\BE Users\$Username"

    }
    else {
    $homedirectory = "\\bi-fishdr-03\Users\$Username"
    }


#set Manager
$Manageruser = Get-ADUser -Identity $Manager


#set displaynames and principal name

$DisplayName = "$FirstName $LastName"

if ( $Company -eq "American Legend Homes" ){

    $PrincipalName = "$Username@$email"
} else {
    
    $PrincipalName = "$FirstName.$LastName@$email"
    }


#End Variables section

#Write-Host "Principal Name = $PrincipalName `n OU = $OU `n HomeDirectory = $homedirectory `n Manager = $Manageruser"

#User creation section

New-ADUser `
    -Name $DisplayName `
    -DisplayName $DisplayName `
    -GivenName $FirstName `
    -Surname $LastName `
    -UserPrincipalName $PrincipalName `
    -AccountPassword $Password `
    -SamAccountName $UserName `
    -Description $Description `
    -HomeDrive "H" `
    -HomeDirectory $homedirectory `
    -Manager $Manageruser `
    -Company $Company `
    -Path $OU `
    -ScriptPath $Script `
    -OfficePhone $Phone `
    -StreetAddress $Street `
    -City $City `
    -State $State `
    -PostalCode $ZipCode `
    -Title $Title `
    -Enabled $true `
    -OtherAttributes @{extensionAttribute1=$CustomAttributes[0];extensionAttribute2=$CustomAttributes[1];extensionAttribute3=$CustomAttributes[2]}
    #>
#End User creation section

#get newly created user

$NewUser = Get-ADUser -Identity $UserName


#Group Assignments section

#Write-Host $NewUser
#$groupobjects = Get-ADGroup -Identity $Groups


Foreach ( $group in $Groups ) {

    #Write-Host $group
    
    Add-ADGroupMember -Identity $group -Members $NewUser

}



#Add-ADPrincipalGroupMembership -Identity $UserName -MemberOf $Groups

#end group assignments

<#For testing purposes only

cd "Z:\Automations\New User Creation\PS Scripts"

[string[]]$groupmembership = Import-Csv -Path "..\Template\ITHelp\groupmembership.csv"
$groupmembership = $groupmembership.Replace("@{name=`"","")
$groupmembership = $groupmembership.replace("`"}","")

.\usercreation.ps1 -FirstName "Testy" -LastName "McTestface" -UserName tmctestface -Company BEITS -Location @("4400 State Highway 121, Suite 900","Lewisville", "TX","75056") -Manager jisanchez -Title "Automation Tester" -CustomAttributes @(' ',' ','2520') -Groups $groupmembership

#>