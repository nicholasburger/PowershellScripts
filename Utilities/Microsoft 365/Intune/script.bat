SET Scriptpath=%~dp0
SET Script=%Scriptpath%hwid.ps1

C:\Windows\System32\WindowsPowershell\v1.0\powershell.exe -noprofile -executionpolicy bypass -Command "&{ Start-Process PowerShell -ArgumentList ' -executionpolicy bypass -file ""%Script%""' -Verb RunAs }"; 
