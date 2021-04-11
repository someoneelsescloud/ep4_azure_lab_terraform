########### Locals ###########
locals {
  name_2     = random_pet.name_2.id
  locationid = random_shuffle.locations.result
}

resource "random_pet" "name_2" {
  length = 1
}

resource "random_shuffle" "locations" {
  input        = ["westus", "westus2"]
  result_count = 2
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

########### Resource Group ###########
resource "azurerm_resource_group" "resourcegroup_2" {
  name     = "${local.name_2}-${local.locationid[1]}-rg-2"
  location = local.locationid[1]
}

########### Storing localadmin in central keyvault ###########
resource "azurerm_key_vault_secret" "localadmin" {
  name         = azurerm_windows_virtual_machine.virtualmachine_2.name
  value        = random_password.password.result
  key_vault_id = data.terraform_remote_state.hub_1.outputs.keyvault_1.id
}

########### Get Workspace Key from KeyVault ###########
data "azurerm_key_vault_secret" "workspacekey" {
  name         = "workspacekey"
  key_vault_id = data.terraform_remote_state.hub_1.outputs.keyvault_1.id
}


########### Storage Account 2 ###########
resource "azurerm_storage_account" "storage_2" {
  name                     = "${local.name_2}storage2"
  resource_group_name = azurerm_resource_group.resourcegroup_2.name
  location            = azurerm_resource_group.resourcegroup_2.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

########### Virtual Machine 2 ###########
resource "azurerm_network_interface" "virtualmachine_2" {
  name                = "${local.name_2}-vm-nic-2"
  location            = azurerm_resource_group.resourcegroup_2.location
  resource_group_name = azurerm_resource_group.resourcegroup_2.name

  ip_configuration {
    name                          = "${local.name_2}-2"
    subnet_id                     = data.terraform_remote_state.hub_1.outputs.subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.virtualmachine_2.id
  }
}

resource "azurerm_public_ip" "virtualmachine_2" {
  name                    = "${local.name_2}-public-vm-nic-2"
  location                = azurerm_resource_group.resourcegroup_2.location
  resource_group_name     = azurerm_resource_group.resourcegroup_2.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 10
}

resource "azurerm_windows_virtual_machine" "virtualmachine_2" {
  name                = "${local.name_2}-vm-2"
  location            = azurerm_resource_group.resourcegroup_2.location
  resource_group_name = azurerm_resource_group.resourcegroup_2.name

  network_interface_ids = [
    azurerm_network_interface.virtualmachine_2.id
  ]
  size           = "Standard_DS1_v2"
  admin_username = "localadmin"
  admin_password = random_password.password.result

  provision_vm_agent = true
  timezone           = "AUS Eastern Standard Time"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "development"
    powermgt    = "lab"
  }

}

resource "azurerm_virtual_machine_extension" "vm2_monitoring" {
  virtual_machine_id         = azurerm_windows_virtual_machine.virtualmachine_2.id
  name                       = "MicrosoftMonitoringAgent"
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  depends_on = [
    azurerm_windows_virtual_machine.virtualmachine_2
  ]

  settings = <<-SETTINGS
    {
      "workspaceId": "${data.terraform_remote_state.hub_1.outputs.law_id}"
    }
  SETTINGS

  protected_settings = <<-PROTECTEDSETTINGS
    {
    "workspaceKey": "${data.azurerm_key_vault_secret.workspacekey.value}"
    }
  PROTECTEDSETTINGS

}

resource "azurerm_virtual_machine_extension" "vm2_depenancy" {
  virtual_machine_id         = azurerm_windows_virtual_machine.virtualmachine_2.id
  name                       = "Microsoft.Azure.Monitoring.DependencyAgent"
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true

  depends_on = [
    azurerm_windows_virtual_machine.virtualmachine_2
  ]
}

