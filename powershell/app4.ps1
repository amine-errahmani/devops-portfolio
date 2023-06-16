param(
    [Parameter(Mandatory=$true, Position=1)][string]$Env,
    [Parameter(Mandatory=$true, Position=2)][string]$DbUser,
    [Parameter(Mandatory=$true, Position=3)][string]$DbPass,
    [Parameter(Mandatory=$true, Position=3)][string]$ENDbPass,
    [Parameter(Mandatory=$true, Position=4)][string]$sa_pass,
    [Parameter(Mandatory=$true, Position=5)][string]$fileshareName
    ) 

############################################ Vars ################################################################
#app DVD
$srcFolder = new-item -ItemType Directory -Path "E:\vendor\Sources" -Force
$binVersion = "app4_191101_p25"
$dvdFolder = "$srcFolder\${binVersion}_dvd_windows"
$source_Folder = "$dvdFolder\$binVersion"
$appFolderBlob = "app4 Artifacts/${binVersion}_dvd_windows.zip"
$dvd = "$srcFolder\${binVersion}_dvd_windows.zip" 
$logFilePath = New-Item -Path "E:\vendor\Logs" -ItemType Directory -Force
$logfile = new-item -Name "app4.log" -Path $logFilePath -ItemType File -Force
$configFilesBlob = "app4 Artifacts/app4_config_Files.zip"
$configFilesFolder = new-item -ItemType Directory -Path "$srcFolder\Config_Files" -Force
$configFilesZip = "$configFilesFolder\app4_config_files.zip"
$app_install_dir = new-item -ItemType Directory -Path "E:\vendor\app4" -Force

#Java
$javaBlob11 = "binaries/jdk-11.0.9_windows-x64_bin.exe"
$java_exe11 = "jdk-11.0.9_windows-x64_bin.exe"
$javaBlob8 = "binaries/jdk-8u231-windows-x64.exe"
$java_exe8 = "jdk-8u231-windows-x64.exe"

$javaOutput8 = "$srcFolder\$java_exe8"
$javaOutput11 = "$srcFolder\$java_exe11"
$jdk_folder11 = "C:\Program Files\Java\jdk-11.0.9"
$jdk_folder8 = "C:\Program Files\Java\jdk1.8.0_231"
$jre_folder = "C:\Program Files\Java\jre1.8.0_231"
$jdk_file8 = "$jdk_folder8\bin\java.exe"
$jdk_file11 = "$jdk_folder11\bin\java.exe"

#Tomcat
$tomcatBlob = "binaries/apache-tomcat-9.0.36-windows-x64.zip"
$tomcat_zip = "apache-tomcat-9.0.36-windows-x64.zip"
$tomcat_output = "$srcFolder\$tomcat_zip"
$tomcat_zip_folder = $srcFolder
$tomcat_install_folder = new-item -ItemType Directory -Path "E:\Tomcat"
$tomcat_service_name = "Tomcat9"
$tomcat_bin_folder = "$tomcat_install_folder\bin"
$tomcat_file = "$tomcat_bin_folder\$tomcat_service_name.exe" 
$tomcat_service_bat = "$tomcat_bin_folder\service.bat"


#Ms Visual C++ 
$vcred_exe = "vc_redist.x64.exe"
$vcred_exe_folder = "$dvdFolder\Tools\vcredist" 

#MS SQL Tools
$sqlnativeclient = "$dvdFolder\Tools\sqlncli.msi"
$sqlcmd = "$dvdFolder\Tools\SqlCmdLnUtils.msi"

$dbms = "ms_sql"
$DBName = "app4DATA"
$jdbc_driver = "$dvdFolder\Tools\JDBC\ms_sql\current\mssql-jdbc-7.0.0.jre8.jar"


#Scoring
if ($Env -eq "test") {
    $DbServer = "sql.test.infra"
    $DbPort = "12345"
} elseif ($Env -eq "dev") {
    $DbServer = "sql.dev.infra"
    $DbPort = "12345"
} elseif ($Env -eq "prd") {
    $DbServer = "sql.prd.infra"
    $DbPort = "12345"
} else {
    throw "Error: Invalid ENV specified"
}



#Web
$app5_src = "$dvdFolder\app5\windows"
$app5_install_dir = new-item -ItemType Directory -Path "E:\vendor\app5" -Force
$ZappFolder = "$app5_install_dir\custom\zapp"
$reg_exe = "$app5_install_dir\system\binx\zwebsvc.exe"


# files download token

$blob_token = '""'

###################################################################################################################

############################################ Functions ############################################################

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

function start-bat {
    Param 
    ( 
        [Parameter(Mandatory = $true, Position = 1)][string]$bat, 
        [array]$argumentList,
        [string]$batOut="$logFilePath\bat_out.log",
        [string]$batErr="$logFilePath\bat_err.log",
        [Boolean]$RunAs,
        [string]$workingDir
    )
    $batname = $bat.Split("\")[-1].Split(".")[0]

    $batOut="$logFilePath\bat_out-$step-$batname.log"
    $batErr="$logFilePath\bat_err-$step-$batname.log"

    log -Output "starting bat file `"$batname`" ..." -Step $step

    if ($RunAs) {
        if ($workingDir){
            Start-Process cmd.exe -verb runas -wait -ArgumentList "/c $bat >$batOut 2>&1" -WorkingDirectory $workingDir
        }     
    }
    else {
        if ($argumentList) {
            Start-Process $bat -ArgumentList $argumentList -RedirectStandardOutput $batOut -RedirectStandardError $batErr -wait
        }
        else {
            Start-Process $bat -RedirectStandardOutput $batOut -RedirectStandardError $batErr -wait
        }
        
    }
    
    $rawBatOut = Get-Content $batOut -Raw
    $rawBatErr = Get-Content $batErr -Raw
    
    if ($rawBatOut) {
        log -Output $rawBatOut -Step "$step , output"
        if ($rawBatOut -like "*error*" ) {
            log -Output "error found" 
            throw "error found please check log file $logfile for more info"
        }
    }
    if ($rawBatErr) {
        log -Output $rawBatErr -Step "$step , error"
        throw "error found please check log file $logfile for more info"
    }
}

###################################################################################################################

########################################## Pre-requisites #########################################################
#init log file 
"###################### app4 Install log ######################" | Out-File -FilePath $logfile
log -Output "starting app4 Pre-requisites Install" -Step "pre-req"

################################# download binaries ############################################
$step = "bin download"
log -Output "download binaries ... " -Step $step

az storage blob download -c vendor -n $appFolderBlob -f $dvd --account-name storage --sas-token $blob_token
az storage blob download -c vendor -n $configFilesBlob -f $configFilesZip --account-name storage --sas-token $blob_token
az storage blob download -c vendor -n $javaBlob8 -f $javaOutput8 --account-name storage --sas-token $blob_token
az storage blob download -c vendor -n $javaBlob11 -f $javaOutput11 --account-name storage --sas-token $blob_token
az storage blob download -c vendor -n $tomcatBlob -f $tomcat_output --account-name storage --sas-token $blob_token


################################# set system wide proxy ############################################
# $step = "proxy"
# log -Output "setting up proxy to $proxy ... " -Step $step
# $reg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
# Set-ItemProperty -Path $reg -name ProxyServer -Value $proxy
# Set-ItemProperty -Path $reg -name ProxyEnable -Value 1
# log -Output "proxy setup done" -Step $step

################################# Encrypted DB password  ############################################
$step = "Encrypted_password"
$passcrypt_zip = "$app_install_dir\system\tool\passcrypt.zip" 
$passcrypt_dest = "$app_install_dir\system\tool\passcrypt"

log -Output "expading archive to $passcrypt_dest ..." -Step $step
try {
    Expand-Archive -Path "$passcrypt_zip" -DestinationPath "$passcrypt_dest" -Verbose
}
catch {
    Write-Host "error :"
    Write-Host $_ 
    Write-Host "error details :"
    Write-Host $_.ErrorDetails
}

$ENDbPassResult = & $passcrypt_dest\encrypt-passwd-console.bat $DbPass
$ENDbPass = $ENDbPassResult[5]
################################# app Folder extract ############################################
$step = "app_folder"

if (Test-Path $dvd){
    Get-ChildItem $srcFolder
    log -Output "binaries downloaded" -Step $step
}
else {
    log -Output "error : binaries not found" -Step $step
    throw "error : binaries not found"
}


log -Output "expading archive to $dvdFolder ..." -Step $step
try {
    Expand-Archive -Path "$dvd" -DestinationPath "$dvdFolder" -Verbose
}
catch {
    Write-Host "error :"
    Write-Host $_ 
    Write-Host "error details :"
    Write-Host $_.ErrorDetails
}

if (Test-Path $dvdFolder){
    log -Output "archive expanded" -Step $step
}
else {
    log -Output "error : archive not expanded" -Step $step
    throw "error : archive not expanded"
}

$step = "config_files"

if (Test-Path $configFilesZip){
    Get-ChildItem $configFilesFolder
    log -Output "Config files downloaded" -Step $step
}
else {
    log -Output "error : Config files not found" -Step $step
    throw "error : Config files not found"
}


log -Output "expading archive to $configFilesFolder ..." -Step $step
try {
    Expand-Archive -Path "$configFilesZip" -DestinationPath "$configFilesFolder" -Verbose
}
catch {
    Write-Host "error :"
    Write-Host $_ 
    Write-Host "error details :"
    Write-Host $_.ErrorDetails
}
log -Output "archive expanded" -Step $step

log -Output "edit app4_env_global_custom with custom db server ..." -Step $step
$config_file = "$configFilesFolder\app4_env_global_custom.bat"
$content = Get-Content $config_file
$content -replace "^set app4_DB_HOST=.*", "set app4_DB_HOST=$DbServer" | Set-Content $config_file
$content = Get-Content $config_file
if ($Env -eq "prp") {
    $content -replace "^set app4_JDBC_DB_URL=.*", "set app4_JDBC_DB_URL=jdbc:sqlserver://$DbServer;databaseName=app4DATA_preprod;instanceName=" | Set-Content $config_file
} else {
    $content -replace "^set app4_JDBC_DB_URL=.*", "set app4_JDBC_DB_URL=jdbc:sqlserver://$DbServer;databaseName=app4DATA;instanceName=" | Set-Content $config_file
}
$content = Get-Content $config_file
$content -replace "^set app4_JDBC_DB_PORT=.*", "set app4_JDBC_DB_PORT=$DbPort" | Set-Content $config_file
$content = Get-Content $config_file
$content -replace "^set app4_DB_LOGIN_USER=.*", "set app4_DB_LOGIN_USER=$DbUser" | Set-Content $config_file
$content = Get-Content $config_file
$content -replace "^set FS_BUS_DB_LOGIN_USER=.*", "set FS_BUS_DB_LOGIN_USER=$DbUser" | Set-Content $config_file
$content = Get-Content $config_file
$content -replace "^set app4_DB_LOGIN_PASSWD_ENCRYPTED=.*", "set app4_DB_LOGIN_PASSWD_ENCRYPTED=$ENDbPass" | Set-Content $config_file
$content = Get-Content $config_file
$content -replace "^set FS_BUS_DB_LOGIN_PASSWD_ENCRYPTEDD=.*", "set FS_BUS_DB_LOGIN_PASSWD_ENCRYPTED=$ENDbPass" | Set-Content $config_file
$content = Get-Content $config_file
$content -replace "^set app4_DB_ENCRYPTED_PASSWD_YN=.*", "set app4_DB_ENCRYPTED_PASSWD_YN=Y" | Set-Content $config_file


log -Output "edit app4analysis_config.properties with custom db server ..." -Step $step
$config_file = "$configFilesFolder\app4analysis_config.properties"
$content = Get-Content $config_file
$content -replace "^db.user = .*", "db.user = $DbUser" | Set-Content $config_file
$content = Get-Content $config_file
$content -replace "^db.pass = .*", "db.pass = $ENDbPass" | Set-Content $config_file
$content = Get-Content $config_file
if ($Env -eq "prp") {
    $content -replace "^db.url = .*", "db.url = jdbc:sqlserver://${DbServer}:${DbPort};databaseName=app4DATA_preprod;instanceName=" | Set-Content $config_file
} else {
    $content -replace "^db.url = .*", "db.url = jdbc:sqlserver://${DbServer}:${DbPort};databaseName=app4DATA;instanceName=" | Set-Content $config_file
}

log -Output "edit app5.ini with custom db pass ..." -Step $step
$config_file = "$configFilesFolder\app5.ini" 
$content = Get-Content $config_file
$content -replace "^Password=.*", "Password=$ENDbPass" | Set-Content $config_file

################################# java Install ####################################################
$step = "java8" 
log -Output "Installing Java 8 ... " -Step $step
Start-Process -FilePath "$srcFolder\$java_exe8" -ArgumentList "/s" -Wait

$timeout_counter = 0
while (!(Test-Path $jdk_file8)) {
    log -Output "java install in progress ..." -Step $step
    $timeout_counter += 10
    if ($timeout_counter -gt 300) {
        log -Output "java install timeout" -Step $step
        throw "java install timeout"
    }
    Start-Sleep 10
}

if (Test-Path $jdk_file8) {
    log -Output "java 8 installed successfully" -Step $step
    log -Output "found java.exe in $jdk_folder8\bin\" -Step $step
}

$step = "java11" 
log -Output "Installing Java 11 ... " -Step $step
Start-Process -FilePath "$srcFolder\$java_exe11" -ArgumentList "/s" -Wait

$timeout_counter = 0
while (!(Test-Path $jdk_file11)) {
    log -Output "java install in progress ..." -Step $step
    $timeout_counter += 10
    if ($timeout_counter -gt 300) {
        log -Output "java install timeout" -Step $step
        throw "java install timeout"
    }
    Start-Sleep 10
}

if (Test-Path $jdk_file11) {
    log -Output "java 11 installed successfully" -Step $step
    log -Output "found java.exe in $jdk_folder11\bin\" -Step $step
}

$env:JAVA_HOME = "$jdk_folder11"
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jdk_folder11 , "Machine")
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", $jdk_folder11 , "User")

$env:JRE_HOME = "$jre_folder"
[System.Environment]::SetEnvironmentVariable("JRE_HOME", $jre_folder , "Machine")
[System.Environment]::SetEnvironmentVariable("JRE_HOME", $jre_folder , "User")

################################# tomcat install & Config ####################################################
$step = "tomcat"
log -Output "Installing Tomcat ... " -Step $step

try {
    Expand-Archive -Path "$tomcat_zip_folder\$tomcat_zip" -DestinationPath $tomcat_install_folder -Verbose
}
catch {
    Write-Host "error :"
    Write-Host $_ 
    Write-Host "error details :"
    Write-Host $_.ErrorDetails
}

Move-Item -Path "$tomcat_install_folder\apache-tomcat-*\*" -Destination $tomcat_install_folder
Remove-Item -Path "$tomcat_install_folder\apache-tomcat-*"
    
$timeout_counter = 0
while (!(Test-Path $tomcat_file)) {
    log -Output "Tomcat install in progress ..." -Step $step
    $timeout_counter += 10
    if ($timeout_counter -gt 300) {
        log -Output "tomcat install timeout" -Step $step
        throw "Tomcat install timeout"
    }
    Start-Sleep 10
}

if (Test-Path $tomcat_file) {
    log -Output "$tomcat_service_name installed successfully" -Step $step
    log -Output "found $tomcat_service_name.exe in $tomcat_bin_folder" -Step $step
}

log -Output "Setting CATALINA_HOME Env variable... " -Step $step
$env:CATALINA_HOME = "$tomcat_install_folder"
[System.Environment]::SetEnvironmentVariable("CATALINA_HOME", $tomcat_install_folder , "User")
[System.Environment]::SetEnvironmentVariable("CATALINA_HOME", $tomcat_install_folder , "Machine")

log -Output "Installing $tomcat_service_name as a service... " -Step $step
start-bat -bat $tomcat_service_bat -argumentList "install" 

log -Output "Starting $tomcat_service_name ... " -Step $step
Set-Service -Name $tomcat_service_name -StartupType Automatic
Start-Service $tomcat_service_name -Verbose 4>&1 2>&1 >> $logfile


log -Output "Configuring Tomcat ... " -Step $step
$context_file = "$tomcat_install_folder\conf\context.xml"
$content = Get-Content $context_file
$content -replace '<Context>', '<Context useHttpOnly="false" >' | Set-Content $context_file

$user_file = "$tomcat_install_folder\conf\tomcat-users.xml"
$content = Get-Content $user_file
$content -replace '</tomcat-users>', "<role rolename=`"tblogin-admin`"/>`n<user username=`"tblogin`" password=`"gwg`" roles=`"tblogin-admin`"/>`n</tomcat-users>" | Set-Content $user_file

log -Output "Tomcat Configured" -Step $step


################################# install Ms Visual C++ ######################################################
$step = "vcredist"
log -Output "Installing Visual C++ ... " -Step $step
Start-Process -FilePath "$vcred_exe_folder\$vcred_exe" -ArgumentList "/install /passive /norestart" -Wait
$vcred_check = Get-WmiObject -Class Win32_Product -Filter "Name LIKE '%Visual C++%'"
if ($vcred_check) {
    log -Output "Visual C++ installed successfully" -Step $step
    foreach ($vc in $($vcred_check | Select-Object name)) {
        log -Output $vc -Step $step
    }
}


################################# install MSSQL tools #########################################################
$step = "sqlnativeclient"
log -Output "Installing SQL Native Client ..." -Step $step
Start-Process -FilePath "msiexec" -ArgumentList "/i $sqlnativeclient", "/quiet", "IACCEPTSQLNCLILICENSETERMS=YES", "/L*V `"$logFilePath\sqlncli.log`"" -Wait

$step = "sqlcmd"
log -Output "Installing SQL cmd ..." -Step $step
Start-Process -FilePath "msiexec" -ArgumentList "/i $sqlcmd", "/quiet", "IACCEPTSQLNCLILICENSETERMS=YES", "/L*V `"$logFilePath\sqlcmd.log`"" -Wait

$sqlcmd_path = "C:\Program Files\Microsoft SQL Server\110\Tools\Binn"

log -Output "adding SQLCMD to PATH ..." -Step $step
$env:PATH = "$sqlcmd_path$env:PATH"
$old_user_path = [System.Environment]::GetEnvironmentVariable("PATH" , "User")
$old_machine_path = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
$new_user_path = "$sqlcmd_path$old_user_path"
$new_machine_path = "$sqlcmd_path$old_machine_path"
[System.Environment]::SetEnvironmentVariable("PATH", $new_user_path , "User")
[System.Environment]::SetEnvironmentVariable("PATH", $new_machine_path , "Machine")

###################################################################################################################

"###################### app4 pre-requisites Install finished ######################" | Write-Host
"###################### app4 pre-requisites Install finished ######################" | Out-File -FilePath $logfile -Append

###################################################################################################################


#init log file 
"###################### app4 Post conf ######################" | Out-File -FilePath $logfile -Append
log -Output "starting app4 Post conf" -Step "post-conf"

########################################## Scoring ################################################################
log -Output "starting Scoring Install" -Step "Scoring"

########### step 1 ###########
$step = "step1"
log -Output "creating app4_ROOT ENV var" -Step $step
$env:app4_ROOT = $app_install_dir
[System.Environment]::SetEnvironmentVariable("app4_ROOT", $app_install_dir , "User")

########### step 2 ###########
$step = "step2"
$bat = "$dvdFolder\$binVersion\system\install\batch\start_install_dir.bat"
Start-bat $bat -argumentList "$dbms", "`"$app_install_dir`"", "`"$source_Folder`"" 

log -Output "Copying system and custom folders" -Step $step
Copy-Item -Path "$dvdFolder\$binVersion\system" -Destination $app_install_dir -Recurse -Force
Copy-Item -Path "$dvdFolder\$binVersion\custom" -Destination $app_install_dir -Recurse -Force
log -Output "Copying xod files" -Step $step
Copy-Item -Path "$app_install_dir\system\parametrization\ms_sql\xod\*" -Destination "$app_install_dir\system\parametrization\lplr\app4\"

########### step 3 ###########
$step = "step3"
log -Output "Copying custom configuration file ..." -Step $step
Copy-Item -Path "$configFilesFolder\app4_env_global_custom.bat" -Destination "$app_install_dir\custom\scoring"
Copy-Item -Path "$app_install_dir\custom\scoring\gwstrtcu.txt.example" -Destination "$app_install_dir\custom\scoring\gwstrtcu.txt"

$config_file = "$app_install_dir\custom\scoring\gwstrtcu.txt"
$content = Get-Content $config_file
$content -replace "^NOTE.*", "NOTE (LONGTERM_FLAG = 'X' WHEN (CONTRA_BIC NE '' AND CONTRA_ACCNO NE ''))" | Set-Content $config_file


$bat = "$app_install_dir\system\set_env.bat"
Start-bat $bat 

########### step 4 ###########
$step = "step4"
$bat = "$app_install_dir\system\install\batch\start_create_global.bat"
start-bat $bat -argumentList "999" 

########### step 5 ###########
$step = "step5"
log -Output "creating ODBC Connector" -Step $step
Add-OdbcDsn -Name "app4" -DriverName "SQL Server" -DsnType "System" -Platform '64-bit' -SetPropertyValue @("Server=$DbServer,$DbPort", "Database=$DBName")
log -Output "ODBC Connector created"

########### step 6 ###########
$step = "step6"
$bat = "$app_install_dir\system\install\batch\start_load_global.bat"
Start-bat $bat -ArgumentList "initial" 

########### step 7 ###########
$step = "step7"
$bat = "$app_install_dir\system\install\batch\start_create_client.bat"
start-bat $bat -ArgumentList "0001", "app401" 

########### step 9 ###########
$step = "step9"
$bat = "$app_install_dir\system\install\batch\start_load_client.bat"
start-bat $bat -ArgumentList "0001", "initial" 

########### step 10 ###########
$step = "step10"
$bat = "$app_install_dir\system\install\batch\start_load_client.bat"
start-bat $bat -ArgumentList "0001", "initial" 

########### step 11 - JDBC ###########
$step = "step11 - JDBC"
log -Output "Deploying JDBC Driver" -Step $step

Copy-Item -Path $jdbc_driver -Destination "$tomcat_install_folder\lib"
Copy-Item -Path $jdbc_driver -Destination "$app_install_dir\custom\web_client\jars"
###################################################################################################################


#################################### Web Installation of Parameterization #########################################
log -Output "starting Web Install" -Step "Web"
Copy-Item -Path "$configFilesFolder\app4analysis_config.properties" -Destination "$app_install_dir\custom\web_client"

Copy-Item -Path "$app5_src\custom" -Destination "$app5_install_dir" -Recurse -Force
Copy-Item -Path "$app5_src\system" -Destination "$app5_install_dir" -Recurse -Force


########### service vendor-Server ###########
$step = "init-vendor"
$serviceName = "vendor-Server"
$serviceValue = Get-Content "$ZappFolder\$serviceName.ini.example"
Set-Content -Value $serviceValue -Path "$ZappFolder\$serviceName.ini"

Start-bat $reg_exe -argumentList "-i $serviceName" #, "-f $ZappFolder\$serviceName.ini" 


########### service app5 ###########
# $step = "init-app5"
# $serviceName = "app5"

Copy-Item -Path "$configFilesFolder\app5.ini" -Destination "$ZappFolder" 
# Start-bat $reg_exe -argumentList "-i $serviceName", "-f $ZappFolder\$serviceName.ini"

###################################################################################################################


########################################## Configuring the application ############################################
log -Output "starting Configuration of the application" -Step "App_config"

########### copy app5web war from dvd ##########
$step = "copy_app5web_war"
log -Output "Copying app5web WAR file ..." -Step $step
$warFile = "$dvdFolder\app5\windows\system\app5web\app5web.war"
$wardest = "$app_install_dir\system\web_client\app5web\"
copy-item -Path $warFile -Destination $wardest

########### Regenerating WAR files step 5.4 ###########
$step = "war-gen_5.4"
log -Output "Regenerating WAR files ..." -Step $step
$warFilesPath = "$app_install_dir\custom\web_client"
$app_service = "vendor-Server"

Stop-Service $tomcat_service_name -passthru

$bat = "$app_install_dir\system\web_client\app4config.bat"
$bat_working_dir = "$app_install_dir\system\web_client\"

Start-bat $bat -RunAs $true -workingDir $bat_working_dir

log -Output "copying generated war files ..." -Step $step
$warfiles = @("app4analysis.war", "app4.war", "tblogin.war", "app5web.war")

foreach ($file in $warfiles) {
    $filePath = "$warFilesPath\$file"
    $destination = "$tomcat_install_folder\webapps"
    if ( Test-Path $filePath ) {
        log -Output "found $filePath" -Step $step
        log -Output "copying it to $destination ..." -Step $step
        try {
            Copy-Item -Path $filePath -Destination $destination -ErrorAction Stop
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            log -Output $ErrorMessage -Step $step
        }
            
        log -Output "file $file copied" -Step $step
    }
    else {
        log -Output "error : warfile $file not found" -Step $step
        throw "error : warfile $file not found"
    }
}

Start-Service $tomcat_service_name

$step = "App_Env_Vars"
log -Output "Setting Environment Variables ..." -Step $step

$env:FS_app5_ROOT = "$app5_install_dir"
[System.Environment]::SetEnvironmentVariable("FS_app5_ROOT", $app5_install_dir , "Machine")
[System.Environment]::SetEnvironmentVariable("FS_app5_ROOT", $app5_install_dir , "User")

$env:app4_ROOT = "$app_install_dir"
[System.Environment]::SetEnvironmentVariable("app4_ROOT", $app_install_dir , "Machine")
[System.Environment]::SetEnvironmentVariable("app4_ROOT", $app_install_dir , "User")

$step = "start-app"
log -Output "Starting application ..." -Step $step

Start-Service $app_service

###################################################################################################################

"###################### app4 post-conf finished ######################" | Write-Host
"###################### app4 post-conf finished ######################" | Out-File -FilePath $logfile -Append
