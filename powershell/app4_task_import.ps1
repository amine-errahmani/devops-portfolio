param(
    [Parameter(Mandatory=$true, Position=1)][string]$username,
    [Parameter(Mandatory=$true, Position=2)][string]$pass
    ) 

##### check elevation ######
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$testAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($testAdmin -eq $false) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    exit $LASTEXITCODE
}


#Vars
$srcFolder = "E:\vendor\Sources"
$tomcat_bin_folder = "E:\Tomcat\bin"
$ZappFolder = "E:\vendor\app5\custom\zapp"

#scheduled Tasks and Batch scripts 
$scheduledTasksUrl = ""
$scheduledTasksOutput = "$srcFolder\scheduled_tasks.zip"
$batchScriptsUrl = ""
$batchScriptsOutput = "$srcFolder\batch_scripts.zip"

$logFilePath = "E:\vendor\Logs"
$logfile = new-item -Name "app4_task_import.log" -Path $logFilePath -ItemType File -Force

function log {
    Param 
    ( 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][ValidateNotNullOrEmpty()][string]$Output, 
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$Step,  
        [Parameter(Mandatory = $false)][string]$Path = $logfile
    )

    $formattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    "$formattedDate - $Step : $Output" | Out-File -FilePath $Path -Append
    "$formattedDate - $Step : $Output" | Write-Host
}



########### Import scheduled tasks ###########
$step = "Import_scheduled-Tasks"
log -Output "download scheduled tasks files ..." -Step $step

invoke-WebRequest -Uri $scheduledTasksUrl -OutFile $scheduledTasksOutput
try {
    Expand-Archive -Path "$scheduledTasksOutput" -DestinationPath "$srcFolder" -Verbose
}
catch {
    Write-Host "error :"
    Write-Host $_ 
    Write-Host "error details :"
    Write-Host $_.ErrorDetails
}

log -Output "download batch scripts ..." -Step $step

invoke-WebRequest -Uri $batchScriptsUrl -OutFile $batchScriptsOutput
try {
    Expand-Archive -Path "$batchScriptsOutput" -DestinationPath "$srcFolder" -Verbose
}
catch {
    Write-Host "error :"
    Write-Host $_ 
    Write-Host "error details :"
    Write-Host $_.ErrorDetails
}

log -Output "copy batch scripts ..." -Step $step

Copy-Item -Path "$srcFolder\*_tomcat.bat" -Destination $tomcat_bin_folder
Copy-Item -Path "$srcFolder\*_app5.bat" -Destination $ZappFolder


log -Output "import scheduled tasks ..." -Step $step
$scheduledTasks = @("Restart app4 Scoring.xml", "app4 Daily Scoring.xml", "start tomcat.xml", "stop tomcat.xml", "start_app5.xml", "stop_app5.xml")

foreach ($st in $scheduledTasks){
    $filePath = "$srcFolder\$st"
    $taskname = ($st.split("."))[0]
    log -Output "importing $taskname task ..." -Step $step
    $xmlContent = (Get-Content $filePath | out-string)
    Register-ScheduledTask -xml $xmlContent -TaskName $taskname -user $username -Password $pass
}


# enable scheduled tasks history
wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true
