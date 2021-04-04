output "resourcegroup_1" {
  value = azurerm_resource_group.resourcegroup_1.name
}

output "subnet_1" {
  value = azurerm_subnet.subnet_1
}

output "law_id" {
    value = azurerm_log_analytics_workspace.law_1.workspace_id
}

output "keyvault_1" {
    value = azurerm_key_vault.keyvault_1
}
