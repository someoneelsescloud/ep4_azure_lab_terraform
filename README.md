# ep4_azure_lab_terraform
EP4: Build an Azure Lab with Terraform

## Scripts

|Name|Description|
|---|---|
|.\scripts\Clean-Terraform|Clean up Terraform working folders - Terraform init will restore the folder|
|.\scripts\Create-ADTestUsers|Create test Active Directory users|
|.\scripts\Create-TFServicePrincipal|Create Service Principal for Terraform|
|.\scripts\Install-Terraform|Downloading and configure Terraform open source|
|.\scripts\Uninstall-AzModule|Uninstall the Az Module - Script above requires AzureRM|

## Single-Deploy Terraform Configuration

|Name|Description|
|---|---|
|.\lab\single-deploy|Deploys virtual network, subnet, keyvault, log analytics workspace, virtual machines with mma agent and dependancy agent|

## Multi-Deploy Terraform Configuration

|Name|Description|
|---|---|
|.\lab\multi-deploy\hub\hub01|Deploys virtual network, subnet, keyvault, log analytics workspace and workspace outputs|
|.\lab\multi-deploy\hub\hub02|Deploys virtual network, subnet and workspace outputs|
|.\lab\multi-deploy\spoke\spoke01|Deploys virtual machine, mma agent, dependancy agent and consumes hub workpace outputs using remote state|
|.\lab\multi-deploy\spoke\spoke02|Deploys virtual machine, mma agent, dependancy agent and consumes hub workpace outputs using remote state|
