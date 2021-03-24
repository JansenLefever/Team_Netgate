# Author: Jansen Levefer, Ethan Denny, Cody Wishart
# Date 3/23/21
# Project: NetGains

# Attribution is done in comments at the start of sections


# Define Variables:

# $adapter = (Get-NetAdapter).ifIndex

$ServerName = "S2W-Server"

$ServerIPParams = @{
  IPAddress             = "10.10.1.5"
  PrefixLength          = "24"
  DefaultGateway        = "10.10.1.1"
  InterfaceIndex        = (Get-NetAdapter).ifIndex
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


Function Step1 {
  # Renames Computer (From Jansen)
  Rename-Computer -NewName $ServerName 

  # Sets a static IP (From Jansen)
  New-NetIPAddress @ServerIPParams

  # Run the Setup-DNS function to install, set, and register DNS (From Jansen)
  Setup-DNS
}

Function Step2 {
  # This line activates domain services, including management tools (From Ethan)
  Add-WindowsFeature ad-domain-services -IncludeManagementTools

  # This line adds a new forest (From Ethan)
  Install-ADDSForest @forestParams
}

Function Step3 {
  # This uses Find-CSV to get the location of the CSV from the user and format it, then stores that location as a variable and then calls Import-Users with that path as an argument (From Cody)
  $directory = Find-CSV
  Import-Users($directory)
}


# This function has the user choose which part of the steup to execute
# Configuring the server requires 2 reboots (one for the name change and one for promotion to DC), and then populating the server is another process
# This function prompts the user to select stage 1, 2, or 3
Function Configure-Server{
  # This section prompts the user to make a selection
  $SetupStep = [int](Read-Host -Prompt "What step of the process would you like to perform?

    1. Rename the computer, set IP address, setup DNS, then restart.
    2. Add AD Domain Services, add a forest, promote the computer to DC, then restart.
    3. Populate the server with users and OUs (no restart needed).
    
Please enter 1, 2, or 3")

  # Write-Host $SetupStep.GetType()
  # Write-Host $SetupStep

  if ( $SetupStep -eq 1 ){
    Write-Host "Running function Step1"
    Step1
    Read-Host -Prompt "System will now restart. Press any key to continue: "
    Restart-Computer -Force 
  }
  elseif ( $SetupStep -eq 2 ){
    Write-Host "Running function Step2"
    Step2
  }
  elseif ( $SetupStep -eq 3 ){
    Write-Host "Running function Step3"
    Step3
  }
  else {
    Write-Host "That wasn't a valid option! Please try again.`n"
    Configure-Server
  }
}



# Main:

# Set up the server
Configure-Server




# Read-Host -Prompt "System will now restart. Press any key to continue: "
# Restart-Computer -Force 

# End