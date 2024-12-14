locals {
  tags            = { ProjectName = "Information Assistant", BuildNumber = var.buildNumber }
  azure_roles     = jsondecode(file("${path.module}/azure_roles.json"))
  selected_roles  = ["CognitiveServicesOpenAIUser", 
                      "CognitiveServicesUser", 
                      "StorageBlobDataOwner",
                      "StorageQueueDataContributor", 
                      "SearchIndexDataContributor"]
}

data "azurerm_client_config" "current" {}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
  number  = false
}

module "entraObjects" {
  source                            = "./core/aad"
  isInAutomation                    = var.isInAutomation
  requireWebsiteSecurityMembership  = var.requireWebsiteSecurityMembership
  randomString                      = random_string.random.result
  azure_websites_domain             = var.azure_websites_domain
  aadWebClientId                    = var.aadWebClientId
  aadMgmtClientId                   = var.aadMgmtClientId
  aadMgmtServicePrincipalId         = var.aadMgmtServicePrincipalId
  aadMgmtClientSecret               = var.aadMgmtClientSecret
  entraOwners                       = var.entraOwners
  serviceManagementReference        = var.serviceManagementReference
  password_lifetime                 = var.password_lifetime
}

data "azurerm_virtual_network" "VNet" {
  name = var.vnetName
  resource_group_name = var.resourceGroupName
}

data "azurerm_subnet" "PrivateEndpointSubnet" {
  name = var.peSubnetName
  virtual_network_name = data.azurerm_virtual_network.VNet.name
  resource_group_name = var.resourceGroupName
}

data "azurerm_subnet" "IntegrationSubnet" {
  name = var.intSubnetName
  virtual_network_name = data.azurerm_virtual_network.VNet.name
  resource_group_name = var.resourceGroupName
}

// Create the Private DNS Zones for all the services
module "privateDnsZoneAzureOpenAi" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.${var.azure_openai_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network.VNet
}

module "privateDnsZoneAzureAi" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.${var.azure_ai_private_link_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network
}

module "privateDnsZoneApp" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.${var.azure_websites_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network
}

module "privateDnsZoneKeyVault" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.${var.azure_keyvault_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network
}

module "privateDnsZoneStorageAccountBlob" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.blob.${var.azure_storage_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network
}


module "privateDnsZoneStorageAccountFile" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.file.${var.azure_storage_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network
}

module "privateDnsZoneStorageAccountTable" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.table.${var.azure_storage_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network
}

module "privateDnsZoneStorageAccountQueue" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.queue.${var.azure_storage_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network
}

module "privateDnsZoneSearchService" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.${var.azure_search_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network
}

module "privateDnsZoneCosmosDb" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.${var.cosmosdb_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network
}

module "privateDnsZoneACR" {
  source             = "./core/network/privateDNS"
  count              = var.is_secure_mode ? 1 : 0
  name               = "privatelink.${var.azure_acr_domain}"
  resourceGroupName  = var.resourceGroupName
  vnetLinkName       = data.azurerm_virtual_network.VNet.name
  virtual_network_id = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  tags               = local.tags
  depends_on = data.azurerm_virtual_network.VNet
}

data "azurerm_network_security_group" "NSG" {
  name                = var.nsgName
  resource_group_name = var.resourceGroupName
}

module "logging" {
  depends_on = [ 
    data.azurerm_virtual_network.VNet,
    data.azurerm_network_security_group.NSG
  ]
  source = "./core/logging/loganalytics"
  logAnalyticsName        = var.logAnalyticsName != "" ? var.logAnalyticsName : "dat-la-${random_string.random.result}"
  applicationInsightsName = var.applicationInsightsName != "" ? var.applicationInsightsName : "dat-ai-${random_string.random.result}"
  location                = var.location
  tags                    = local.tags
  skuName                 = "PerGB2018"
  resourceGroupName       = var.resourceGroupName
  is_secure_mode                        = var.is_secure_mode
  privateLinkScopeName                  = "dat-ampls-${random_string.random.result}"
  privateDnsZoneNameMonitor             = "privatelink.${var.azure_monitor_domain}"
  privateDnsZoneNameOms                 = "privatelink.${var.azure_monitor_oms_domain}"
  privateDnSZoneNameOds                 = "privatelink.${var.azure_monitor_ods_domain}"
  privateDnsZoneNameAutomation          = "privatelink.${var.azure_automation_domain}"
  privateDnsZoneResourceIdBlob          = var.is_secure_mode ? module.privateDnsZoneStorageAccountBlob[0].privateDnsZoneResourceId : null
  privateDnsZoneNameBlob                = var.is_secure_mode ? module.privateDnsZoneStorageAccountBlob[0].privateDnsZoneName : null
  groupId                               = "azuremonitor"
  subnet_name                           = var.is_secure_mode ? data.azurerm_subnet.PrivateEndpointSubnet.name : null
  vnet_name                             = var.is_secure_mode ? data.azurerm_virtual_network.VNet.name : null
  ampls_subnet_CIDR                     = var.peSubnetCidr
  vnet_id                               = var.is_secure_mode ? data.azurerm_virtual_network.VNet.id : null
  nsg_id                                = var.is_secure_mode ? data.azurerm_network_security_group.NSG.id : null
  nsg_name                              = var.is_secure_mode ? data.azurerm_network_security_group.NSG.name : null
}

module "storage" {
  depends_on = [ 
    data.azurerm_virtual_network.VNet,
    data.azurerm_subnet.PrivateEndpointSubnet
  ]
  source                          = "./core/storage"
  CloudShellIP                    = var.CloudShellIP
  name                            = var.storageAccountName != "" ? var.storageAccountName : "datstore${random_string.random.result}"
  location                        = var.location
  tags                            = local.tags
  accessTier                      = "Hot"
  allowBlobPublicAccess           = false
  resourceGroupName               = var.resourceGroupName
  arm_template_schema_mgmt_api    = var.arm_template_schema_mgmt_api
  key_vault_name                  = module.kvModule.keyVaultName
  deleteRetentionPolicy = {
    days                          = 7
  }
  containers                      = ["content","website","upload","function","logs","config"]
  queueNames                      = ["pdf-submit-queue","pdf-polling-queue","non-pdf-submit-queue","media-submit-queue","text-enrichment-queue","image-enrichment-queue","embeddings-queue"]
  is_secure_mode                  = var.is_secure_mode
  subnet_name                     = var.is_secure_mode ? data.azurerm_subnet.PrivateEndpointSubnet.name : null
  vnet_name                       = var.is_secure_mode ? data.azurerm_virtual_network.VNet.name : null
  private_dns_zone_ids            = var.is_secure_mode ? [module.privateDnsZoneStorageAccountBlob[0].privateDnsZoneResourceId,
                                       module.privateDnsZoneStorageAccountFile[0].privateDnsZoneResourceId,
                                        module.privateDnsZoneStorageAccountTable[0].privateDnsZoneResourceId,
                                        module.privateDnsZoneStorageAccountQueue[0].privateDnsZoneResourceId] : null
  network_rules_allowed_subnets   = var.is_secure_mode ? [data.azurerm_subnet.PrivateEndpointSubnet.id] : null
  kv_secret_expiration            = var.kv_secret_expiration
  logAnalyticsWorkspaceResourceId = module.logging.logAnalyticsId
}

module "kvModule" {
  source                        = "./core/security/keyvault" 
  CloudShellIP                    = var.CloudShellIP  
  name                          = "dat-kv-${random_string.random.result}"
  location                      = var.location
  kvAccessObjectId              = data.azurerm_client_config.current.object_id 
  resourceGroupName             = var.resourceGroupName
  tags                          = local.tags
  is_secure_mode                = var.is_secure_mode
  subnet_name                   = var.is_secure_mode ? data.azurerm_subnet.PrivateEndpointSubnet.name : null
  vnet_name                     = var.is_secure_mode ? data.azurerm_virtual_network.VNet.name : null
  subnet_id                     = var.is_secure_mode ? data.azurerm_subnet.PrivateEndpointSubnet.id : null
  private_dns_zone_ids          = var.is_secure_mode ? [module.privateDnsZoneApp[0].privateDnsZoneResourceId] : null
  depends_on                    = [ module.entraObjects, data.azurerm_virtual_network.VNet, data.azurerm_subnet.PrivateEndpointSubnet ]
  azure_keyvault_domain         = var.azure_keyvault_domain
  arm_template_schema_mgmt_api  = var.arm_template_schema_mgmt_api
}

// DEPLOYMENT OF AZURE CUSTOMER ATTRIBUTION TAG
resource "azurerm_resource_group_template_deployment" "customer_attribution" {
  count               = var.cuaEnabled ? 1 : 0
  name                = "pid-${var.cuaId}"
  resource_group_name = var.resourceGroupName
  deployment_mode     = "Incremental"
  template_content    = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": []
}
TEMPLATE
}