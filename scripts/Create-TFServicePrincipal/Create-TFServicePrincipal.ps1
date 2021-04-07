# Initialize
$ErrorActionPreference = "Stop"
$VerbosePreference = "SilentlyContinue"
$userName = $env:USERNAME

# Service Principal Role
$spnRole = "contributor"

# Initialize subscription
$isAzureModulePresent = Get-Module -Name AzureRM* -ListAvailable
if ([String]::IsNullOrEmpty($isAzureModulePresent) -eq $true) {
    Write-Output "Script requires AzureRM modules. Obtain from https://github.com/Azure/azure-powershell/releases."
    return
}

Import-Module -Name AzureRM.Profile
Write-Output "Provide your credentials to access your Azure subscription - See Login Pop-up Window"
Connect-AzureRmAccount

# Collect AzureRM Subscription details to create Service principal
$azureAccount = Get-AzureRmSubscription
$tenantId = $azureAccount.TenantId
$subscriptionId = $azureAccount.Id

# Generate random suffix for name
$appRandom = ("0123456789".tochararray() | sort {Get-Random})[0..4] -join ''
$appDisplayName = "terraform-spn-$appRandom"

# Service Principal URI
$homePage = "http://$tenantId/$appDisplayName"
$identifierUri = $homePage

# Generate random password - shown at the end after created
$appPassword = ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | sort {Get-Random})[0..15] -join ''

# Check if AD Application Identifier URI is unique
Write-Output "Verifying App URI is unique ($identifierUri)"
$existingApplication = Get-AzureRmADApplication -IdentifierUri $identifierUri
if ($existingApplication -ne $null) {
    $appId = $existingApplication.ApplicationId
    Write-Output "An AAD Application already exists with App URI $identifierUri (Application Id: $appId). Choose a different app display name" 
    return
}

# Create a new AD Application
Write-Output "Creating a new Application in AAD (App URI - $identifierUri)"
$secureAppPassword = $appPassword | ConvertTo-SecureString -AsPlainText -Force
$azureAdApplication = New-AzureRmADApplication -DisplayName $appDisplayName -HomePage $homePage -IdentifierUris $identifierUri -Password $secureAppPassword
$appId = $azureAdApplication.ApplicationId
Write-Output "Azure AAD Application creation completed successfully (Application Id: $appId)"

# Create new SPN
Write-Output "Creating a new SPN"
$spn = New-AzureRmADServicePrincipal -ApplicationId $appId
$spnName = $spn.ServicePrincipalName
Write-Output "SPN creation completed successfully (SPN Name: $spnName)"

# Assign role to SPN
Write-Output "Waiting for SPN creation to reflect in Directory before Role assignment"
Start-Sleep 15
Write-Output "Assigning role ($spnRole) to SPN App ($appId)"
New-AzureRmRoleAssignment -RoleDefinitionName $spnRole -ServicePrincipalName $appId
Write-Output "SPN role assignment completed successfully"

# Print the values
Write-Output "Copy and Paste below values for Terraform AzureRM Provider in providers.tf"
Write-Output "--------------------------------------------------------------------------"
Write-Output "provider ""azurerm"" {"
Write-Output "`n"
Write-Output "subscription_id = ""$subscriptionId"""
Write-Output "client_id = ""$appId"""
Write-Output "client_secret = ""$appPassword"""
Write-Output "tenant_id = ""$tenantId"""
Write-Output "`n"
Write-Output "features {}"
Write-Output "}"
Write-Output "--------------------------------------------------------------------------"
Write-Output "** appPassword saved to $appDisplayName.txt **"
$appPassword | Out-File "$appDisplayName.txt"