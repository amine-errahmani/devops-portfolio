param(
    [Parameter(Mandatory=$true, Position=1)][string]$username,
    [Parameter(Mandatory=$true, Position=2)][string]$pass,
    [Parameter(Mandatory=$true, Position=3)][string]$fileshareName,
    [Parameter(Mandatory=$true, Position=4)][string]$sa_pass,
    [Parameter(Mandatory=$true, Position=5)][string]$Env,
    [Parameter(Mandatory=$true, Position=6)][string]$target
    )

#prepare storage account credentials
[Byte[]] $key = (1..16)
$secret1 = ConvertTo-SecureString -String $pass -AsPlainText -Force
$secret2 = ConvertFrom-SecureString -SecureString $secret1 -Key $key
$secret3 = ConvertTo-SecureString -String $secret2 -Key $key
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $secret3

$session = New-PSSession -ComputerName $target -Credential $creds


#importing tasks
write-host "importing tasks .... "
Invoke-Command -Session $session -ScriptBlock { E:\scripts\app4_task_import.ps1 $username $pass } 

#mounting fileshare
write-host "mounting fileshare ...."

Invoke-Command -Session $session -ScriptBlock { E:\scripts\app4_fileshare.ps1 $fileshareName $sa_pass $Env } 
