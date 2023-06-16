$Action = New-ScheduledTaskAction -Execute 'powershell' -Argument '-NonInteractive -NoLogo -NoProfile -File "c:\ServerConfig\Connecitity-monitor.ps1"'
$Trigger = New-ScheduledTaskTrigger -Once -At 12am -RepetitionInterval (New-TimeSpan -Minutes 5)
$Settings = New-ScheduledTaskSettingsSet
$Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal
Register-ScheduledTask -TaskName 'Connection Test' -InputObject $Task