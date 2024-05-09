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
        ElseIf ( Select-String -InputObject $DisplayName -Pattern "Office", "Nitro", "Microsoft Office", "Dropbox" -Quiet ) {
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


Write-Host "Installing Software"

#Installing VMWare Client
&"$ScriptRoot\Install\VMware-Horizon-View-Client.exe" /s /v`"/qn REBOOT=ReallySuppress VDM_SERVER=vdi2.brightco.com`" | Out-Null

Write-Host "Complete Install.
Disable Wireless"

#Disable wireless adapter
Get-WMIObject win32_networkadapter -Filter "Name LIKE '%Wireless%'" | Invoke-WMIMethod -Name Disable

#Disable IPv6 stack
New-ItemProperty “HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\” -Name “DisabledComponents” -Value 0xffffffff -PropertyType “DWord"

#Add OpenDNS servers on Local Area Connection
netsh interface ipv4 add dnsserver "Local Area Connection" address=208.67.222.222 index=1
netsh interface ipv4 add dnsserver "Local Area Connection" address=208.67.220.220 index=2

#Setup IE settings
Write-Host "Setup IE settings"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "Start Page" -Value 'www.google.com'
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "Secondary Start Pages" -Value ''
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Internet Explorer\Main" -Name "Start Page" -Value 'www.brightindustries.com'
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Internet Explorer\Main" -Name "Secondary Start Pages" -Value ''


#Setting power settings to not sleep
Write-Host "Setting Power Scheme"
$CurrentScheme = Powercfg -getactivescheme
$CurrentGUID = ( $CurrentScheme.Split() )[3]
PowerCfg -import "$ScriptRoot\scheme.pow" $CurrentGUID

Write-Host "Creating vdiuser"
#Make vdiuser account
net user "<user>" "<Password>" /ADD

Write-Host "Starting Windows Updates"
#Run Windows Update
& 'CScript.exe' "$ScriptRoot\WUA_SearchDownloadInstall.vbs" | Out-Null





