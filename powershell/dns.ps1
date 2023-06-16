param(
    [Parameter(Mandatory=$true, Position=1)][string]$action,
    [Parameter(Mandatory=$true)][string]$alias,
    [Parameter(Mandatory=$false)][string]$target,
    [Parameter(Mandatory=$true)][string]$type,
    [Parameter(Mandatory=$true)][string]$domain,
    [Parameter(Mandatory=$true)][string]$dnsserver
    )



# Vars
$ttl = "01:00:00"


switch ($action) {
    create {
        if ($target) {
            switch ($type) {
                cname {
                    $record = Get-DnsServerResourceRecord -Name $alias -ZoneName $domain -RRType $type -ComputerName $dnsserver -ErrorAction SilentlyContinue
                    if ($record) {
                        Write-Output "Dns Record already Exists"
                    }
                    else {
                        Add-DnsServerResourceRecordCName -Name $alias -HostNameAlias $target -ZoneName $domain -PassThru -ComputerName $dnsserver
                        $record = Get-DnsServerResourceRecord -Name $alias -ZoneName $domain -RRType $type -ComputerName $dnsserver
                        if ($record) {
                            Write-Output "Dns Record created successfully"
                        } 
                        else {
                            Write-Error "Error: Something Went wrong, Dns Record $alias does not exist"    
                        }
                    }
                }
                A {
                    $record = Get-DnsServerResourceRecord -Name $alias -ZoneName $domain -RRType $type -ComputerName $dnsserver -ErrorAction SilentlyContinue
                    if ($record) {
                        Write-Output "Dns Record already Exists"
                    }
                    else {
                        Add-DnsServerResourceRecordA -Name $alias -ZoneName $domain -IPv4Address $target -AllowUpdateAny -TimeToLive $ttl -PassThru -ComputerName $dnsserver
                        $record = Get-DnsServerResourceRecord -Name $alias -ZoneName $domain -RRType $type -ComputerName $dnsserver
                        if ($record) {
                            Write-Output "Dns Record created successfully"
                        } 
                        else {
                            Write-Error "Error: Something Went wrong, Dns Record $alias does not exist"    
                        }
                    }
                }
            }
        }
        else {
            Write-Error "Error: Target not supplied , it is mandatory for create action "    
        }  
    }
    delete {
        $ToDel = Get-DnsServerResourceRecord -Name $alias -ZoneName $domain -RRType $type -ComputerName $dnsserver
        Remove-DnsServerResourceRecord -InputObject $ToDel -ZoneName $domain -Force -ComputerName $dnsserver
        
        $del = Get-DnsServerResourceRecord -Name $alias -ZoneName $domain -RRType $type -ComputerName $dnsserver -ErrorAction SilentlyContinue
        if ($del) {
            Write-Error "Error: record still exists"
        }
        else {
            Write-Output "Record deleted successfully"
        }
    }
    Default {
        Write-Error "no valid action specified"
    }
}