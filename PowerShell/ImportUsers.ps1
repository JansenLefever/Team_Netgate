<#
    Script Name:                  ImportUsers 
    Class Name:                   Ops 301
    Author Name:                  Cody Wishart
    Date of latest revision:      3/22/21
    Purpose:                      Import users into a domain
#>


# Variable dictionary 
$userParams = @{
    name         = "Franz Ferdinand"
    office       = "Springfield, OR"
    title        = "TPS Reporting Lead"
    mail         = "ferdi@GlobeXpower.com"
    company      = "GlobeX USA"
    department   = "TPS"
}

# Function to add specified user from dictionary 
Function importUsers($name, $office, $title, $mail, $company, $department) {
    New-ADUser -Name $name -Office $office -OtherAttributes @{ 'title'=$title;
                                                               'mail'=$mail;
                                                               'company'=$company;
                                                               'department'=$department
                                                                }
}

# Main
importUsers @userParams
