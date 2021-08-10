## Create-TFServicePrincipal.ps1

- Creates Service Principal
- Assigns Service Principal Contributor access to the Subscription
- Outputs AzureRM Provider connection configuration

**Updated to use Az PowerShell module.**

### CHANGELOG ###
[Date: 31-07-21] 
- Updated script to use Az Module (previously AzureRM).
- Removed Contributor assignment (New-AzADServicePrincipal defaults to Contributor assignment).
- Added Az-Context to check if already logged in.
- Added check for Az Module, load if not loaded.
- Added WarningPreference to SilentlyContinue

**Original from: https://gist.github.com/coreyasmith - @Sitecore MVP and Solutions Architect.**
