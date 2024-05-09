<####################################################################################


    Script Name: UpdateCredentials.ps1

    Author: Nicholas Burger

    Version: 0.1

    Purpose: This script will create or update an encrpyted xml file which contains 
             credentials that can be used by utilizing the import-clixml command.
             Can create both Active Directory and Microsoft 365 credentials. *Note you
             will need to account for multi-factor authentication if you are using 
             credentials that use this.

    Usage:  When prompted for Credentials please provide the Active Directory credentials
            for the new service account. You must be on the same device and user profile
            to use the import-clixml command successfully after creating the xml.
#######################################################################################>

$credentials = Get-Credential


Export-Clixml -Path "$PSScriptRoot\Credentials\localcred.xml" -InputObject $credentials


$username = $credentials.GetNetworkCredential().UserName
$Password = $credentials.GetNetworkCredential().SecurePassword

$username = $username.Replace("BRIGHTCO\","") + "@billc.com"

$credentials = New-Object System.Management.Automation.PSCredential ($username,$password)

Export-Clixml -Path "$PSScriptRoot\Credentials\cloudcred.xml" -InputObject $credentials




