########### Locals ###########
locals {
  name_1     = random_pet.name_1.id
  locationid = random_shuffle.locations.result
}

resource "random_pet" "name_1" {
  length = 1
}

resource "random_shuffle" "locations" {
  input        = ["eastus", "eastus2"]
  result_count = 2
}

########### Management 1  ###########
resource "azurerm_resource_group" "resourcegroup_1" {
  name     = "${local.name_1}-${local.locationid[0]}-rg-1"
  location = local.locationid[0]
}

resource "azurerm_virtual_network" "virtualnetwork_1" {
  name                = "${local.name_1}-${local.locationid[0]}-vnet-1"
  location            = azurerm_resource_group.resourcegroup_1.location
  resource_group_name = azurerm_resource_group.resourcegroup_1.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "subnet_1" {
  name                 = "${local.name_1}-${local.locationid[0]}-subnet-1"
  virtual_network_name = azurerm_virtual_network.virtualnetwork_1.name
  resource_group_name  = azurerm_resource_group.resourcegroup_1.name
  address_prefixes     = ["192.168.1.0/24"]
}

########### Log Analytics Workspace ###########
resource "azurerm_log_analytics_workspace" "law_1" {
  name                = "${local.name_1}-${local.locationid[0]}-logs-1"
  location            = azurerm_resource_group.resourcegroup_1.location
  resource_group_name = azurerm_resource_group.resourcegroup_1.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

########### VMInsights Solution ###########
resource "azurerm_log_analytics_solution" "vminsights" {
  solution_name         = "VMInsights"
  location              = azurerm_resource_group.resourcegroup_1.location
  resource_group_name   = azurerm_resource_group.resourcegroup_1.name
  workspace_resource_id = azurerm_log_analytics_workspace.law_1.id
  workspace_name        = azurerm_log_analytics_workspace.law_1.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }

}

########### Data sources for Log Analytics Workspace ###########
resource "azurerm_log_analytics_datasource_windows_event" "app_1" {
  name                = "windows-app-logs"
  resource_group_name = azurerm_resource_group.resourcegroup_1.name
  workspace_name      = azurerm_log_analytics_workspace.law_1.name
  event_log_name      = "Application"
  event_types         = ["error", "information", "warning"]
}

resource "azurerm_log_analytics_datasource_windows_event" "sys_1" {
  name                = "windows-sys-logs"
  resource_group_name = azurerm_resource_group.resourcegroup_1.name
  workspace_name      = azurerm_log_analytics_workspace.law_1.name
  event_log_name      = "System"
  event_types         = ["error", "information", "warning"]
}

resource "azurerm_log_analytics_datasource_windows_performance_counter" "cpu_1" {
  name                = "perf-cpu-1"
  resource_group_name = azurerm_resource_group.resourcegroup_1.name
  workspace_name      = azurerm_log_analytics_workspace.law_1.name
  object_name         = "CPU"
  instance_name       = "*"
  counter_name        = "CPU"
  interval_seconds    = 10
}

resource "azurerm_log_analytics_datasource_windows_performance_counter" "cpu_2" {
  name                = "perf-cpu-2"
  resource_group_name = azurerm_resource_group.resourcegroup_1.name
  workspace_name      = azurerm_log_analytics_workspace.law_1.name
  object_name         = "Processor"
  instance_name       = "_Total"
  counter_name        = "% Processor Time"
  interval_seconds    = 10
}

resource "azurerm_log_analytics_datasource_windows_performance_counter" "mem_1" {
  name                = "perf-memory-1"
  resource_group_name = azurerm_resource_group.resourcegroup_1.name
  workspace_name      = azurerm_log_analytics_workspace.law_1.name
  object_name         = "Memory"
  instance_name       = "*"
  counter_name        = "Available MBytes"
  interval_seconds    = 10
}

resource "azurerm_log_analytics_datasource_windows_performance_counter" "mem_2" {
  name                = "perf-memory-2"
  resource_group_name = azurerm_resource_group.resourcegroup_1.name
  workspace_name      = azurerm_log_analytics_workspace.law_1.name
  object_name         = "Memory"
  instance_name       = "*"
  counter_name        = "% Committed Bytes in Use"
  interval_seconds    = 10
}

########### KeyVault ###########
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault_1" {
  name                        = "${local.name_1}-${local.locationid[0]}-kv-1"
  location                    = azurerm_resource_group.resourcegroup_1.location
  resource_group_name         = azurerm_resource_group.resourcegroup_1.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false

  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "Backup",
      "Delete",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_key_vault_secret" "workspacekey" {
  name         = "workspacekey"
  value        = azurerm_log_analytics_workspace.law_1.primary_shared_key
  key_vault_id = azurerm_key_vault.keyvault_1.id
}
