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

This is a simplied Terraform deployment, where by all the configuration files are within the single folder i.e. a Terraform workspace. The following diagram shows all the components that will be deployed!
![single-deploy-diagram](files/single-deploy-diagram.png)

|Name|Description|
|---|---|
|.\lab\single-deploy|Deploys virtual network, subnet, keyvault, log analytics workspace, virtual machines with mma agent and dependancy agent|



## Multi-Deploy Terraform Configuration
This is a multi workspace Terraform deployment. The deployment has been split into a hub and spoke deployment, where by the networking and platform related sevices are stored in hub 01. Outputs are used in the hubs to output the platform resource information. The spokes use remote state look ups back into the hub to bind or consume the services in the hubs. This deployment method contains 4 workspaces and will need to be manually deployed in sequence with the hubs and then the spokes to follow. The following diagram shows all the components that will be deployed!
![multi-deploy-diagram](files/multi-deploy-diagram.png)

**Note: The deployments use random location generated and this may cause issues if you have a resource group in a region and trying to deploying a nic in another region. If you wanted to fix this, you will have to pin the random location to a single location, rather than the two regions!**

|Name|Description|
|---|---|
|.\lab\multi-deploy\hub\hub01|Deploys virtual network, subnet, keyvault, log analytics workspace and workspace outputs|
|.\lab\multi-deploy\hub\hub02|Deploys virtual network, subnet and workspace outputs|
|.\lab\multi-deploy\spoke\spoke01|Deploys virtual machine, mma agent, dependancy agent and consumes hub workpace outputs using remote state|
|.\lab\multi-deploy\spoke\spoke02|Deploys virtual machine, mma agent, dependancy agent and consumes hub workpace outputs using remote state|

Full episode video: https://www.someoneelsescloud.com/episodes/ep4-build-an-azure-lab-with-terraform

Listen to the audio only version:
Google Podcasts: https://cutt.ly/ogvwqTl   
Apple Podcasts: https://cutt.ly/YgvweNk
Spotify Podcasts: https://cutt.ly/igvwezs
Stitcher Radio: https://cutt.ly/ugvwewo
Tunein Radio: https://cutt.ly/Xgvwwpf

Visit the website for more information: www.someoneelsescloud.com
See all links to all platforms here: https://www.someoneelsescloud.com/links
