<#
    Script Name:                  ImportUsers 
    Class Name:                   Ops 301
    Author Name:                  Cody Wishart
    Date of latest revision:      3/23/21
    Purpose:                      Import users into a domain from a csv
#>

# Functions
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

Function Import-Users () {
    $directory = Find-CSV
    $csv = Import-Csv -Path $directory
    for($i = 0; $i -lt $csv.length; $i++){
        New-ADUser -Name $csv[$i].Name -Office $csv[$i].Office -OtherAttributes @{ 'title'=$csv[$i].Title;
                                                                                   'mail'=$csv[$i].Email;
                                                                                   'company'=$csv[$i].Company;
                                                                                   'department'=$csv[$i].Department
                                                                                   }
    }
} 

# Main
Import-Users 
