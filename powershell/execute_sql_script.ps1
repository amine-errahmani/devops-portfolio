param(
    [Parameter(Mandatory=$true)][string]$UserName,
    [Parameter(Mandatory=$true)][string]$pass,
    [Parameter(Mandatory=$true)][string]$sqlServerInstance,
    [Parameter(Mandatory=$true)][string]$dbName,
    [Parameter(Mandatory=$true)][string]$sqlScriptpath
    )
    
import-module -name sqlserver

$securePass = ConvertTo-SecureString -String $pass -AsPlainText -Force
$sqlcreds = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $securePass

$sqlServerObject = Get-SqlInstance -ServerInstance $sqlServerInstance -Credential $sqlcreds

Invoke-Sqlcmd -ServerInstance $sqlServerObject -Database $dbName -Credential $sqlcreds -InputFile $sqlScriptpath -OutputSqlErrors $true

