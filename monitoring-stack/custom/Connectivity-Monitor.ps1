$connections = import-csv C:\ServerConfig\hosts.csv
$logPath = "C:\ServerConfig\connections.log"
$debugLogPath = "C:\ServerConfig\connections_debug.log"
$psPingBinPath = "C:\ServerConfig"
foreach ($connection in $connections) {
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss:fff"
$targetHost = $connection.host
$port = $connection.port
$q = "${targetHost}:${port}"
"$timestamp - $q :" | Out-File -FilePath $debugLogPath -Append
try {
    Set-Location -path $psPingBinPath
    $test = .\psping.exe -n 1 -i 0 -q $q -nobanner -accepteula
    $test | Out-String -Stream | ForEach-Object {if($_) {' ' * 15 + $_}} | Out-File -FilePath $debugLogPath -Append
    "" | Out-File -FilePath $debugLogPath -Append #new line
    $result = ($test | Select-String -Pattern 'Average' -CaseSensitive -SimpleMatch).ToString().Split("=")[3].Trim(' ms')
    $status = "success" 
}
catch {
    $status = "error"
}
$logLine = "time=$timestamp status=$status target=$targetHost port=$port averageMs=$result"
$logLine | Out-File -FilePath $logPath -Append -Encoding utf8
#reset result
$result=$null
}