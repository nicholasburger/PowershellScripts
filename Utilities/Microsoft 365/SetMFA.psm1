Import-Module MSOnline

function Set-MFAState {
    [cmdletbinding()]
    param(
        
        #ObjectID parameter
        [Parameter(ValueFromPipelineByPropertyName=$True,Mandatory=$true)]
        $ObjectID,

        #User principal name
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        $UserPrincipalName,

        #State 
        [Parameter(Mandatory=$true)]
        [ValidateSet("Disabled","Enabled","Enforced")]
        [String]$State
    )

    Process {
        
        $Requirement = @()

        if ( $State -ne "Disabled") {
            
            $Requirement = [Microsoft.Online.Administration.StrongAuthenticationRequirement]::new()
            
            $Requirement.RelyingParty = "*"

            $Requirement.State = $State

            $Requirements += $Requirement
        }

        Set-MsolUser -ObjectId $ObjectID -UserPrincipalName $UserPrincipalName -StrongAuthenticationRequirements $Requirements

    }
}