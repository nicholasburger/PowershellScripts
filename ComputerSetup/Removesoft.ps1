#Get the root directory for the script
$ScriptRoot = $MyInvocation.Mycommand.Path
$ScriptRoot = $ScriptRoot.Replace("Setup.ps1", "")

#Uninstalling Lenovo bloatware and other software
Function Uninstall ($DisplayName) {


    Set-Variable -Name ThirtyMachine -Value "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant
    Set-Variable -Name SixtyMachine -Value "HKLM:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant
    Set-Variable -Name ThirtyUser -Value "HKCU:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant
    Set-Variable -Name SixtyUser -Value "HKCU:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall" -Option Constant

    $regs = $ThirtyMachine, $SixtyMachine, $ThirtyUser, $SixtyUser

    foreach ($reg in $regs) { 
        if (Test-Path $reg) {
            $SubKeys = Get-ItemProperty "$reg\*"
        }
        else {
            $SubKeys = $null
        }
        foreach ($key in $SubKeys) {
            if ($key.DisplayName -match "$DisplayName") {

                Write-Host "Found Software " $key.DisplayName
                if ($key.UninstallString -match "^msiexec") {
                    $startGUID = $key.UninstallString.IndexOf("{") + 1
                    $endGuid = $key.UninstallString.IndexOf("}") - $startGUID
                    $stringer = $key.UninstallString.Substring($startGUID, $endGuid)
                    Write-Host "Uninstaller Known, now uninstalling"
                    &msiexec `/passive `/x `{$stringer`} `/norestart  | Out-Null

                }
                if ($key.UninstallString.Replace('"', "") -match 'uninstall.exe\Z' -or $key.UninstallString.replace('"', "") -match 'setup.exe' -or $key.UninstallString.replace('"', "") -match 'unins000.exe' -or $key.UninstallString.replace('"', "") -match 'InstStub.exe'  ) {

                    if ( $key.UninstallString.replace('"', "") -match 'InstStub.exe' ) {
                        $stringer = $key.uninstallstring.replace('"', "" )
    
                        $stringer = $stringer.replace('/X /ARP', "")
    
                        &$stringer /x /arp /s /v`"/qn /norestart`"
                    }
                    else {
                        $stringer = $key.UninstallString.Replace('"', "")

                        if (Test-Path $stringer ) {
                            Write-Host "Possible Uninstaller found. Trying" $stringer "/verysilent /norestart"
                            &$stringer /verySilent /norestart | Out-Null
                        }
                    }
                }
            }
        }
    }
}



$RegUninstallPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
"HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

For ( $Count = 0 ; $Count -lt 2 ; $Count++ ) {

    Get-ChildItem -Path $RegUninstallPath[$Count] | ForEach-Object {
    
        $Publisher = ($_).GetValue("Publisher")
        $UninstallString = ($_).GetValue("UninstallString")
        $DisplayName = ($_).GetValue("DisplayName")
        [bool]$Found = $false


        If ( Select-String -InputObject $Publisher -Pattern "Lenovo", "Dell" -Quiet ) {
            $Found = $true
        }
        ElseIf ( Select-String -InputObject $DisplayName -Pattern "Nitro", "Microsoft Office" -Quiet ) {
            $Found = $true
        }



        If ( $Found ) {
            Write-Host "Trying Uninstall $DisplayName"
            Uninstall($DisplayName) 
            $Found = $false
            Write-Host "$UninstallString"
        }
    

    }


}
Write-Host "Uninstall Complete"

