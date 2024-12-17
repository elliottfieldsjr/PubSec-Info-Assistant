locals {
  tags            = { ProjectName = "Information Assistant", BuildNumber = var.buildNumber }
  azure_roles     = jsondecode(file("${path.module}/azure_roles.json"))
  selected_roles  = ["CognitiveServicesOpenAIUser", 
                      "CognitiveServicesUser", 
                      "StorageBlobDataOwner",
                      "StorageQueueDataContributor", 
                      "SearchIndexDataContributor"]
}

data "azurerm_client_config" "HubSub" {
  provider = azurerm.HUBSub
}

data "azurerm_client_config" "IdentitySub" {
  provider = azurerm.IDENTITYSub
}

data "azurerm_client_config" "OperationsSub" {
  provider = azurerm.OPERATIONSSub
}

data "azurerm_client_config" "SharedServicesSub" {
  provider = azurerm

}
module "entraObjects" {
  source                            = "./core/aad"
  ResourceNamingConvention = var.ResourceNamingConvention
  ObjectID = data.azurerm_client_config.HubSub.object_id
  isInAutomation                    = var.isInAutomation
  requireWebsiteSecurityMembership  = var.requireWebsiteSecurityMembership
  azure_websites_domain             = var.azure_websites_domain
  aadWebClientId                    = var.aadWebClientId
  aadMgmtClientId                   = var.aadMgmtClientId
  aadMgmtServicePrincipalId         = var.aadMgmtServicePrincipalId
  aadMgmtClientSecret               = var.aadMgmtClientSecret
  entraOwners                       = var.entraOwners
  serviceManagementReference        = var.serviceManagementReference
  password_lifetime                 = var.password_lifetime
}


data "azurerm_resource_group" "InfoAssistRG" {
  provider            = azurerm
  name                = var.InfoAssistResourceGroupName
}

data "azurerm_virtual_network" "InfoAssistVNet" {
  provider            = azurerm
  name                = var.InfoAssistVNetName
  resource_group_name = var.InfoAssistResourceGroupName
}

data "azurerm_subnet" "InfoAssistPESubnet" {
  provider              = azurerm
  name                  = var.InfoAssistPESubnetName
  virtual_network_name  = data.azurerm_virtual_network.InfoAssistVNet.name
  resource_group_name   = var.InfoAssistResourceGroupName
}

data "azurerm_subnet" "InfoAssistINTSubnet" {
  provider              = azurerm
  name                  = var.InfoAssistINTSubnetName
  virtual_network_name  = data.azurerm_virtual_network.InfoAssistVNet.name
  resource_group_name   = var.InfoAssistResourceGroupName
}

data "azurerm_network_security_group" "InfoAssistNSG" {
  provider            = azurerm
  name                = var.InfoAssistNSGName
  resource_group_name = var.InfoAssistResourceGroupName
}

data "azurerm_private_dns_zone" "AzureAutomationPDZ" {
  provider            = azurerm.HUBSub
  name                = "privatelink.${var.azure_automation_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "AzureCRPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_acr_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "AzureWebPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_websites_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "BlobStoragePDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_blob_storage_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "FileStoragePDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_file_storage_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "QueueStoragePDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_queue_storage_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "TableStoragePDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_table_storage_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "CognitiveServicesPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_ai_document_intelligence_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "DocumentsPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.cosmosdb_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "MonitorPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_monitor_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "MonitorODSPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_monitor_ods_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "MonitorOMSPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_monitor_oms_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "OpenAIPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_openai_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "SearchServicePDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_search_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_private_dns_zone" "KeyVaultPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_keyvault_domain}"
  resource_group_name = var.APDZResourceGroupName
}

data "azurerm_key_vault" "InfoAssistKeyVault" {
  provider              = azurerm.HUBSub    
  name                  = var.KVName
  resource_group_name   = var.KVResourceGroupName
}

data "azurerm_log_analytics_workspace" "ExistingLAW" {
  provider            = azurerm.OPERATIONSSub
  name                = var.LAWName
  resource_group_name = var.LAWResourceGroupName
}

module "logging" {
  source = "./core/logging/loganalytics"
  providers = {
    azurerm = azurerm
    azurerm.HUBSub = azurerm.HUBSub,
    azurerm.OPERATIONSSub = azurerm.OPERATIONSSub
  }  
  ResourceNamingConvention = var.ResourceNamingConvention
  location                = var.location
  tags                    = local.tags
  skuName                 = "PerGB2018"
  InfoAssistResourceGroupName           = var.InfoAssistResourceGroupName
  APDZResourceGroupName                 = var.APDZResourceGroupName
  LAWResourceGroupName                  = var.LAWResourceGroupName
  LAWName                               = var.LAWName
  AMPLSName                             = var.AMPLSName
  is_secure_mode                        = var.is_secure_mode
  privateDnsZoneNameMonitor             = "privatelink.${var.azure_monitor_domain}"
  privateDnsZoneNameMonitorId           = data.azurerm_private_dns_zone.MonitorPDZ.id
  privateDnsZoneNameOms                 = "privatelink.${var.azure_monitor_oms_domain}"
  privateDnsZoneNameOmsId               = data.azurerm_private_dns_zone.MonitorOMSPDZ.id
  privateDnSZoneNameOds                 = "privatelink.${var.azure_monitor_ods_domain}"
  privateDnSZoneNameOdsId               = data.azurerm_private_dns_zone.MonitorODSPDZ.id
  privateDnsZoneNameAutomation          = "privatelink.${var.azure_automation_domain}"
  privateDnsZoneNameAutomationId        = data.azurerm_private_dns_zone.AzureAutomationPDZ.id
  privateDnsZoneResourceIdBlob          = var.is_secure_mode ? data.azurerm_private_dns_zone.BlobStoragePDZ.id : null
  privateDnsZoneNameBlob                = var.is_secure_mode ? data.azurerm_private_dns_zone.BlobStoragePDZ.name : null
  groupId                               = "azuremonitor"
  subnet_name                           = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  vnet_name                             = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name: null
  ampls_subnet_CIDR                     = var.InfoAssistPESubnetCidr
  vnet_id                               = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.id : null
  nsg_id                                = var.is_secure_mode ? data.azurerm_network_security_group.InfoAssistNSG.id: null
  nsg_name                              = var.is_secure_mode ? data.azurerm_network_security_group.InfoAssistNSG.name : null
}

module "storage" {
  source                          = "./core/storage"
  providers = {
    azurerm = azurerm
    azurerm.HUBSub = azurerm.HUBSub,
    azurerm.OPERATIONSSub = azurerm.OPERATIONSSub
  }   
  CloudShellIP                    = var.CloudShellIP
  name                            = var.storageAccountName != "" ? var.storageAccountName : var.InfoAssistStorageAccountName
  location                        = var.location
  tags                            = local.tags
  accessTier                      = "Hot"
  allowBlobPublicAccess           = false
  InfoAssistResourceGroupName     = var.InfoAssistResourceGroupName
  InfoAssistStorageAccountName    = var.InfoAssistStorageAccountName
  KVResourceGroupName             = var.KVResourceGroupName  
  arm_template_schema_mgmt_api    = var.arm_template_schema_mgmt_api
  key_vault_name                  = var.KVName
  deleteRetentionPolicy = {
    days                          = 7
  }
  containers                      = ["content","website","upload","function","logs","config"]
  queueNames                      = ["pdf-submit-queue","pdf-polling-queue","non-pdf-submit-queue","media-submit-queue","text-enrichment-queue","image-enrichment-queue","embeddings-queue"]
  is_secure_mode                  = var.is_secure_mode
  subnet_name                     = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  vnet_name                       = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_ids            = var.is_secure_mode ? [data.azurerm_private_dns_zone.BlobStoragePDZ.id,
                                       data.azurerm_private_dns_zone.FileStoragePDZ.id,
                                        data.azurerm_private_dns_zone.TableStoragePDZ.id,
                                        data.azurerm_private_dns_zone.QueueStoragePDZ.id] : null
  network_rules_allowed_subnets   = var.is_secure_mode ? [data.azurerm_subnet.InfoAssistPESubnet.id] : null
  kv_secret_expiration            = var.kv_secret_expiration
  logAnalyticsWorkspaceResourceId = data.azurerm_log_analytics_workspace.ExistingLAW.id
}