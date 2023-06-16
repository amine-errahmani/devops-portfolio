param(
    [Parameter(Mandatory=$true, Position=1)][string]$action,
    [Parameter(Mandatory=$true)][string]$alias,
    [Parameter(Mandatory=$true)][string]$target,
    [Parameter(Mandatory=$true)][string]$type,
    [Parameter(Mandatory=$true)][string]$user,
    [Parameter(Mandatory=$true)][string]$pass,
    [Parameter(Mandatory=$true)][string]$dnsserver,
    [Parameter(Mandatory=$true)][string]$domain

    )

#prepare service account credentials
[Byte[]] $key = (1..16)
$secret1 = ConvertTo-SecureString -String $pass -AsPlainText -Force
$secret2 = ConvertFrom-SecureString -SecureString $secret1 -Key $key
$secret3 = ConvertTo-SecureString -String $secret2 -Key $key
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $secret3

#copy dns script
Copy-Item -Path .\dns.ps1 -Destination $env:ALLUSERSPROFILE

#requestInfo
$requestInfo = New-Object System.Diagnostics.ProcessStartInfo
$requestInfo.FileName = "powershell.exe"
$requestInfo.CreateNoWindow = $true
$requestInfo.WorkingDirectory = $env:ALLUSERSPROFILE
$requestInfo.RedirectStandardOutput = $true
$requestInfo.RedirectStandardError = $true
$requestInfo.UseShellExecute = $false
$requestInfo.UserName = $creds.GetNetworkCredential().UserName
$requestInfo.Domain = $creds.GetNetworkCredential().Domain
$requestInfo.Password = $creds.Password
$requestInfo.Arguments = "$env:ALLUSERSPROFILE\dns.ps1 $action -alias $alias -target $target -type $type -domain $domain -dnsserver $dnsserver"

$request = New-Object System.Diagnostics.Process
$request.StartInfo = $requestInfo
$request.Start() | Out-Null
$request.WaitForExit(100000)

$result = $request.StandardOutput.ReadToEnd()
$result

#cleanup dns script
Remove-Item -Path "$env:ALLUSERSPROFILE\dns.ps1"