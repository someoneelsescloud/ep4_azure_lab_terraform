## Create-ServicePrincipal.ps1

Script creates randomised test users in Active Directory

Requires the following variables to be updated:

- NumUsers - Default is "100"
- OU - Distinguished Name of OU
- Departments - Default is IT, Finance, Logistics, Sourcing, Human Resources
- Names - Default is to use the NamesList.csv file
- Password - Default password for all test users

**Requires the ActiveDirectory PowerShell module.**

**Sourced from: [Tailspintoys – 365lab.net](https://365lab.net/2014/01/08/create-test-users-in-a-domain-with-powershell/) - Office 365, Azure and Microsoft Infrastructure with a touch of PowerShell.**
