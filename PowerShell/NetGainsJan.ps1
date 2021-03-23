# Renames Computer

Rename-Computer -NewName "SunToWater" 

# Global Var
$adapter = (Get-NetAdapter).ifIndex

# Sets a static IP

function Setup-StaticIp{
  $ip = "10.10.1.5"
  $prefix = "24"
  $GW = "10.10.1.1"
  New-NetIPAddress -IPAddress $ip -PrefixLength $prefix -InterfaceIndex $adapter -DefaultGateway $GW
}

# Installs and Sets DNS

function Setup-DNS{
  Install-WindowsFeature DNS -IncludeManagementTools
  Set-DnsClientServerAddress -InterfaceAlias $adapter -ServerAddresses ("LocalHost")
  Register-DnsClient
}

Setup-StaticIp

Setup-DNS

Restart-Computer -Force 
