
$prom_dest = "$env:ProgramFiles\Promtail\"

Copy-Item -Path "C:\ServerConfig\promtail_config.yml" -Destination "$prom_dest"

Restart-Service -Name Promtail

