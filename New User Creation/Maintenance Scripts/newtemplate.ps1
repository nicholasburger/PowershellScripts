<#
#######################################################################################################
    NAME: New Template Creation
    AUTHOR: Nick Burger 
            
    DESCRIPTION: This script will create the template for use in the New User Creation script
    UPDATES:
    DATE            VERAION         NOTES
    08/16/2023      0.0.1           Initial creation of script
########################################################################################################
#>


param (

    #User to copy to create template   
    [Parameter(Mandatory=$true)]
    [string]
    $UserName,

    #Template's internal name - needs to have no spaces, this is the name that will be used in the automation behind the scenes
    [Parameter(Mandatory=$true)]
    [string]
    $TemplateName
)

Import-Module ActiveDirectory

#Variable Initialization
[string]$attribute1 = "-"
[string]$attribute2 = "-"
[string]$attribute3 = "-"
[string[]]$groups = $null

New-Item -Path "$PSScriptRoot\..\Template\" -Name $TemplateName -ItemType Directory | Out-Null

$User = Get-ADUser -Identity $UserName -Properties *,extensionAttribute1,extensionAttribute2,extensionAttribute3


Get-ADPrincipalGroupMembership $User| Select-Object -Property 'name'| Export-Csv -Path "$PSScriptRoot\..\Template\$TemplateName\groupmembership.csv" -Force -NoTypeInformation

if ( $User.extensionAttribute1 -ne $null ){
    $attribute1 = $User.extensionAttribute1
    Write-Output "$UserName Custom Attribute 1 = $($User.extensionAttribute1)"
}



if ( $User.extensionAttribute2 -ne $null ){
    $attribute2 = $User.extensionAttribute2
    Write-Output "$UserName Custom Attribute 2 = $($User.extensionAttribute2)"
}



if ( $User.extensionAttribute3 -ne $null ){
    $attribute3 = $User.extensionAttribute3
    Write-Output "$UserName Custom Attribute 3 = $($User.extensionAttribute3)"
}

Out-File -InputObject "Attribute,$attribute1,$attribute2,$attribute3" -FilePath "$PSScriptRoot\..\Template\$TemplateName\extensionattributes.csv" -Force

Out-File -InputObject "$($User.ScriptPath)" -Force -FilePath "$PSScriptRoot\..\Template\$TemplateName\logonscript.txt"
