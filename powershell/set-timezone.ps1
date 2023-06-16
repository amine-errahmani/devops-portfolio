  
# Variables
$TimeZone = "Arabian Standard Time"
$NTPServer1 = ""
$NTPServer2 = ""
# Configure NTP and restart service
Set-TimeZone -Id $TimeZone -PassThru
Push-Location
Set-Location HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers
Set-ItemProperty . 0 $NTPServer1
Set-ItemProperty . 1 $NTPServer2
Set-ItemProperty . "(Default)" "0"
Set-Location HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters
Set-ItemProperty . NtpServer "$NTPServer1,0x9 $NTPServer2,0x2"
Pop-Location
Stop-Service w32time
Start-Service w32time