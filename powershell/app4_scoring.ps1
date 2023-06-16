$date = Get-Date -Format "yyyy-MM-dd"
$timestamp = Get-Date -Format "HHmmss"

$input = "E:\vendor\app4\client\0001\data\input"
$dataDest = New-Item -Path "E:\vendor\app4\client\0001\log_archive\data" -ItemType "directory" -Force

$bat = "E:\vendor\app4\system\scoring\batch\start_scoring.bat"
$argument = "0001"
$log = "$dataDest\scoring.log"
$errorlog = "$dataDest\scoring_error.log"

"$date - $timestamp scoring started" | Out-File -FilePath $log

$directoryInfo = Get-ChildItem $input | Measure-Object
if ($directoryInfo.count -eq 0 ){

    "no data to process" | Out-File -FilePath $log -Append
    exit 0

} else {

    Start-Process $bat -ArgumentList $argument -RedirectStandardOutput $log -RedirectStandardError $errorlog -wait

    Move-Item -Path "$input\*" -Destination $dataDest -Force

}

$finishTimestamp = Get-Date -Format "HHmmss"

"$date - $finishTimestamp scoring finished" | Out-File -FilePath $log -Append