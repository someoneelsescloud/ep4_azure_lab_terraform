# Initialize
$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"
$userName = $env:USERNAME

# Initialize subscription
$isAzModulePresent = Get-Module -Name Az.* -ListAvailable
if ([String]::IsNullOrEmpty($isAzModulePresent) -eq $true) {
    Write-Output "Script requires Az modules. Obtain from https://github.com/Azure/azure-powershell."
    return
}
else {
    Write-Output "Importing Az module.."
    Import-Module Az
}

# Checking if connected to Azure
if (!(Get-AzContext)) {
    try {
        Write-Output "Connecting to Azure."
        Write-Output "Provide your credentials to access your Azure subscription - See Login Pop-up Window"
        Connect-AzAccount
    }
    catch {
        Write-Output "Error: Cannot connect to Azure!"
    }
}

# Collect AzSubscription details to create Service principal
$azAccount = Get-AzSubscription
$tenantId = $azAccount.TenantId
$subscriptionId = $azAccount.Id

# Generate random suffix for name
$appRandom = ("0123456789".tochararray() | sort {Get-Random})[0..4] -join ''
$appDisplayName = "terraform-sp-$appRandom"

# Service Principal URI
$homePage = "http://$tenantId/$appDisplayName"
$identifierUri = $homePage

# Generate random password - shown at the end after created
$appPassword = ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | sort {Get-Random})[0..15] -join ''

# Check if AD Application Identifier URI is unique
Write-Output "Verifying App URI is unique ($identifierUri)"
$existingApplication = Get-AzADApplication -IdentifierUri $identifierUri
if ($existingApplication -ne $null) {
    $appId = $existingApplication.ApplicationId
    Write-Output "An AAD Application already exists with App URI $identifierUri (Application Id: $appId). Choose a different app display name" 
    return
}

# Create a new AD Application
Write-Output "Creating a new Application in AAD (App URI - $identifierUri)"
$secureAppPassword = $appPassword | ConvertTo-SecureString -AsPlainText -Force
$azureAdApplication = New-AzADApplication -DisplayName $appDisplayName -HomePage $homePage -IdentifierUris $identifierUri -Password $secureAppPassword
$appId = $azureAdApplication.ApplicationId
Write-Output "Azure AAD Application creation completed successfully (Application Id: $appId)"

# Create new SPN
Write-Output "Creating a new SPN"
$spn = New-AzADServicePrincipal -ApplicationId $appId
$spnName = $spn.DisplayName
Write-Output "SPN creation completed successfully (SPN Name: $spnName)"

# Print the values
Write-Output "Creating providers.tf configuration file for Terraform AzureRM Provider authentication."
Set-Content "providers.tf" "provider ""azurerm"" {"
Add-Content "providers.tf" "`n"
Add-Content "providers.tf" "subscription_id = ""$subscriptionId"""
Add-Content "providers.tf" "client_id = ""$appId"""
Add-Content "providers.tf" "client_secret = ""$appPassword"""
Add-Content "providers.tf" "tenant_id = ""$tenantId"""
Add-Content "providers.tf" "`n"
Add-Content "providers.tf" "features {}"
Add-Content "providers.tf" "}"
Write-Output "** appPassword saved to $appDisplayName.txt **"
$appPassword | Out-File "$appDisplayName.txt"
