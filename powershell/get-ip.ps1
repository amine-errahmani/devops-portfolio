param(
    [Parameter(Mandatory=$true, Position=1)][string]$alias,
    [Parameter(Mandatory=$true)][string]$version,
    [Parameter(Mandatory=$true)][string]$env
    )


$inventory = "./ansible/inventory/$version/ips/inventory_$env.ini"

$content = Get-Content $inventory | Select-String "\[$alias\]" -Context 1

return $content.Context.PostContext
