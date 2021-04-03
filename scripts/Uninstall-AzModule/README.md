# How to uninstall Azure PowerShell modules
Source: https://docs.microsoft.com/en-us/powershell/azure/uninstall-az-ps?view=azps-5.7.0

List Az Versions (required to uninstall)
`Get-InstalledModule -Name Az -AllVersions`

*Example:*
`Uninstall-AzModule -Name Az -Version 1.8.0`