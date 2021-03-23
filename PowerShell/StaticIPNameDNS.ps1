# Author: Jansen Levefer
# Date 3/23/21
# Project: NetGains

# Renames Computer

Rename-Computer -NewName "S2W-Server" 

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
  Set-DnsClientServerAddress -InterfaceIndex $adapter -ServerAddresses ("LocalHost")
  Register-DnsClient
}

Setup-StaticIp

Setup-DNS

Restart-Computer -Force 
