param(
    [Parameter(Mandatory=$true)][string]$UserName,
    [Parameter(Mandatory=$true)][string]$pass,
    [Parameter(Mandatory=$true)][string]$sqlServerInstance,
    [Parameter(Mandatory=$true)][string]$dbName
    )   
    
import-module -name sqlserver

$securePass = ConvertTo-SecureString -String $pass -AsPlainText -Force
$sqlcreds = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $securePass

$sqlServerObject = Get-SqlInstance -ServerInstance $sqlServerInstance -Credential $sqlcreds

$db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $sqlServerObject, $dbName

$db.Create()

$dbdate = $db.CreateDate
$createddbname = $db.Name
$dbid = $db.ID
Write-Host "db create time is : $dbdate"
Write-Host "db name is: $createddbname"
Write-Host "db ID is: $dbid"

