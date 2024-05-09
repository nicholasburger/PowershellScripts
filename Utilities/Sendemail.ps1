


$username = "name@emaildomain.com"
$password = ConvertTo-SecureString "password" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username,$password)


Send-MailMessage -To nicholas.burger@billc.com `
    -From scanner@billc.com `
    -Subject "Test" `
    -Body "Test" `
    -SmtpServer smtp.office365.com `
    -Port 587 `
    -UseSsl `
    -Credential $cred