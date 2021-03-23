# Script:                       create_OU.ps1
# Author:                       Ethan Denny
# Date of latest revision:      3/22/2021
# Purpose:     This script will add a new Operational Unit in AD DS



$OUParams = @{
    # Description                     = 
    # DisplayName                     = 
    Name                            = "Test"
    # ProtectFromAccidentalDeletion   = 
    # Server                          = 
    # ManagedBy                       = 
}


New-ADOrganizationalUnit @OUParams -WhatIf