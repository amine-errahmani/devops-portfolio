param(
    [Parameter(Mandatory=$true, Position=1)][string]$fileshareName,
    [Parameter(Mandatory=$true, Position=2)][string]$sa_pass,
    [Parameter(Mandatory=$true, Position=3)][string]$Env
    ) 

#Vars
$app_install_dir = "E:\vendor\app4"

$logFilePath = "E:\vendor\Logs"
$logfile = new-item -Name "app4_fileshare.log" -Path $logFilePath -ItemType File -Force

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


########### Mount Azure File Share ###########
$step = "Mount_File_Share"
log -Output "Mounting Azure File Share ..." -Step $step

$sa = "$fileshareName.file.core.windows.net"
$fileshareEnv = $Env.ToLower()
$fileshare = "\\$sa\$fileshareEnv"
$connectTestResult = Test-NetConnection -ComputerName $sa -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmdkey /add:"$sa" /user:"Azure\$fileshareName" /pass:"$sa_pass"
    # Mount the drive
    New-PSDrive -Name "Y" -PSProvider FileSystem -Root $fileshare -Persist -Scope Global #-Credential $creds
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
$inputFolder = "$app_install_dir\client\0001\data\input"
Rename-Item -Path $inputFolder -NewName $inputFolder"_bak"
New-Item -ItemType SymbolicLink -Path $inputFolder -Target $fileshare

Get-ChildItem $inputFolder