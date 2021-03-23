# Script:                       create_forest.ps1
# Author:                       Ethan Denny
# Date of latest revision:      3/22/2021
# Purpose:     This script will add a new forest in AD DS

# Walked through by this video: https://www.youtube.com/watch?v=bWF1-rhPh5E&ab_channel=TechSnips


# This line adds DNS, including management tools
Add-WindowsFeature ad-domain-services -IncludeManagementTools

# Save at password as a secure string for the Directory Services Restore Mode (DSRM) password
# (I think)
$safeModePw = ConvertTo-SecureString -String 'p@$$w0rd10' -AsPlainText -Force

$forestParams = @{
    DomainName                      = "suntowater.globex.com"
    DomainNetbiosName               = "suntowater"
    InstallDns                      = $true
    SafeModeAdministratorPassword   = $safeModePw
}

Install-ADDSForest @forestParams
