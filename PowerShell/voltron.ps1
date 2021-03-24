# Author: Jansen Levefer, Ethan Denny, Cody Wishart
# Date 3/23/21
# Project: NetGains

# Attribution is done in comments at the start of sections


# Define Variables:

# $adapter = (Get-NetAdapter).ifIndex

$ServerName = "S2W-Server"

$ServerIPParams = @{
  ip              = "10.10.1.5"
  prefix          = "24"
  GW              = "10.10.1.1"
  InterfaceIndex  = (Get-NetAdapter).ifIndex
}


# These two variables contain the configuration settings for setting up a domain and a forest
$safeModePw = ConvertTo-SecureString -String 'p@$$w0rd10' -AsPlainText -Force

$forestParams = @{
  DomainName                      = "suntowater.globexpower.com"
  DomainNetbiosName               = "suntowater"
  InstallDns                      = $true
  SafeModeAdministratorPassword   = $safeModePw
}



# Define Functions:

# Installs and Sets DNS
# From Jansen
function Setup-DNS{
    Install-WindowsFeature DNS -IncludeManagementTools
    Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).ifIndex -ServerAddresses ("LocalHost")
    Register-DnsClient
}


# This function collects the portions of the script that set up the server (as opposed to the parts taht populate it), making it easier to run the initial setup on its own
Function Configure-Server{
  # Renames Computer (From Jansen)
  Rename-Computer -NewName @ServerName 

  # Sets a static IP (From Jansen)
  New-NetIPAddress @ServerIPParams

  # Run the Setup-DNS function to install, set, and register DNS (From Jansen)
  Setup-DNS

  # This line activates domain services, including management tools (From Ethan)
  Add-WindowsFeature ad-domain-services -IncludeManagementTools

  # This line adds a new forest (From Ethan)
  Install-ADDSForest @forestParams
}



# Imports a CSV of users
# From Cody
Function Find-CSV () {
  $check = Read-Host -Prompt 'Is the CSV file downloaded on this computer? y | n'
  if ( $check -ieq "y" ) {
      $dir = Read-Host -Prompt "Enter the CSV's directory (SHIFT-right click a file and click 'Copy as Path' and paste it here)"
      return $dir
  } 
  elseif ( $check -ieq "n") {
      $url = Read-Host -Prompt "Enter the shareable link for the spreadsheet (Make sure the file is public first)"
      $url = ($url).TrimEnd("edit?usp=sharing")
      $url = $url + "export?format=csv"
      Invoke-WebRequest $url -OutFile "C:\Users\Administrator\Documents\temp.csv"
      return "C:\Users\Administrator\Documents\temp.csv" 
  }
}

Function Import-Users ($PathToCSV) {
  $csv = Import-Csv -Path $PathToCSV
  Write-Host $csv
  # for($i = 0; $i -lt $csv.length; $i++){
  #     New-ADUser -Name $csv[$i].Name -Office $csv[$i].Office -OtherAttributes @{ 'title'=$csv[$i].Title;
  #                                                                                'mail'=$csv[$i].Email;
  #                                                                                'company'=$csv[$i].Company;
  #                                                                                'department'=$csv[$i].Department
  #                                                                                }
  foreach($user in $csv) {
    # Format user details:
    $Username = ("$($user.FirstName).$($user.LastName)").Replace(" ", "")
    $UserDetails = @{
      Name                    = "$($user.FirstName) $($user.LastName)"
      GivenName               = $user.FirstName
      Surname                 = $user.LastName
      UserPrincipalName       = $Username
      EmailAddress            = "$Username@globexpower.com"
      Title                   = $user.title
      Department              = $user.Department
      Company                 = $user.Company
      # Path                    = $null
      ChangePasswordAtLogon   = $true
      Enabled                 = $true
    }
    
    # Create user
    Write-Host @UserDetails
    # New-ADUser @UserDetails -WhatIf
  }
}




# Main:

# Set up the server
Configure-Server


#### This section covers Cody's script
# This uses Find-CSV to get the location of the CSV from the user and format it, then stores that location as a variable and then calls Import-Users with that path as an argument
$directory = Find-CSV
Import-Users($directory)

# Restart-Computer -Force 

# End