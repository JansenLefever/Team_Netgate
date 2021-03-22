<#
    Script Name:                  installPython3 
    Class Name:                   Ops 301
    Author Name:                  Cody Wishart
    Date of latest revision:      3/22/21
    Purpose:                      Install python3 using choco on a new windows install
#>

# Function
Function Install-ChocoAndPython3 {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco install -y python3
}

# Main
Install-ChocoAndPython3
