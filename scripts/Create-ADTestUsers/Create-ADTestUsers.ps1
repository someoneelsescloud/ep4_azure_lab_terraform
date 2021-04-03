<#
.SYNOPSIS
    The Script creates test users to your demo domain based on first and last namnes from csv. 
.PARAMETER NumUsers
    Integer - number of users to create, default 100.
.NOTES
    File Name: CreateTestADUsers.ps1
    Author   : Johan Dahlbom, johan[at]dahlbom.eu
    Blog     : 365lab.net
    The script are provided “AS IS” with no guarantees, no warranties, and they confer no rights.    
#>
param ([parameter(Mandatory = $false)]
    [int]
    $NumUsers = "100"
)
#Define variables
$OU = "OU=TestUsers,OU=Cloud Inc.,DC=cloud,DC=lab"
$Departments = @("IT", "Finance", "Logistics", "Sourcing", "Human Resources")
$Names = Import-CSV NamesList.csv
$firstnames = $Names.Firstname
$lastnames = $Names.Lastname
$Password = "Password1"

#Import required module ActiveDirectory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    throw "Module GroupPolicy not Installed"
}

while ($NumUsers -gt 0) {
    #Choose a 'random' department Firstname and Lastname
    $i = Get-Random -Minimum 0 -Maximum $firstnames.count
    $firstname = $FirstNames[$i]
    $i = Get-Random -Minimum 0 -Maximum $lastnames.count
    $lastname = $LastNames[$i]
    $i = Get-Random -Minimum 0 -Maximum $Departments.count
    $Department = $Departments[$i]
    
    #Generate username and check for duplicates
    $username = $firstname.Substring(0, 3).tolower() + $lastname.Substring(0, 3).tolower()
    $exit = 0
    $count = 1
    do { 
        try { 
            $userexists = Get-AdUser -Identity $username
            $username = $firstname.Substring(0, 3).tolower() + $lastname.Substring(0, 3).tolower() + $count++
        }
        catch {
            $exit = 1
        }
    }
    while ($exit -eq 0)

    #Set Displayname and UserPrincipalNBame
    $displayname = $firstname + " " + $lastname
    $upn = $username + "@" + (get-addomain).DNSRoot

    #Create the user
    Write-Host "Creating user $username in $ou"
    New-ADUser –Name $displayname –DisplayName $displayname `
        –SamAccountName $username -UserPrincipalName $upn `
        -GivenName $firstname -Surname $lastname -description "Test User" `
        -Path $ou –Enabled $true –ChangePasswordAtLogon $false -Department $Department `
        -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -force) 

    $NumUsers-- 
}
