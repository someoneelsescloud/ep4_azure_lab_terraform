########### Locals ###########
locals {
  name_2     = random_pet.name_2.id
  locationid = random_shuffle.locations.result
}

resource "random_pet" "name_2" {
  length = 1
}

resource "random_shuffle" "locations" {
  input        = ["eastus", "westus"]
  result_count = 2
}

########### Management 2 ###########
resource "azurerm_resource_group" "resourcegroup_2" {
  name     = "${local.name_2}-${local.locationid[1]}-rg-2"
  location = local.locationid[1]
}

resource "azurerm_virtual_network" "virtualnetwork_2" {
  name                = "${local.name_2}-${local.locationid[1]}-vnet-2"
  location            = azurerm_resource_group.resourcegroup_2.location
  resource_group_name = azurerm_resource_group.resourcegroup_2.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_2" {
  name                 = "${local.name_2}-${local.locationid[0]}-subnet-2"
  virtual_network_name = azurerm_virtual_network.virtualnetwork_2.name
  resource_group_name  = azurerm_resource_group.resourcegroup_2.name
  address_prefixes     = ["10.0.1.0/24"]
}