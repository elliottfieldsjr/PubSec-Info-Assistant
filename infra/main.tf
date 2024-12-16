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
  provider = azurerm.SHAREDSERVICESSub

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
  provider            = azurerm.SHAREDSERVICESSub
  name                = var.InfoAssistResourceGroupName
}

data "azurerm_virtual_network" "InfoAssistVNet" {
  provider            = azurerm.SHAREDSERVICESSub
  name                = var.InfoAssistVNetName
  resource_group_name = var.InfoAssistResourceGroupName
}

data "azurerm_subnet" "InfoAssistPESubnet" {
  provider              = azurerm.SHAREDSERVICESSub
  name                  = var.InfoAssistPESubnetName
  virtual_network_name  = data.azurerm_virtual_network.InfoAssistVNet.name
  resource_group_name   = var.InfoAssistResourceGroupName
}

data "azurerm_subnet" "InfoAssistINTSubnet" {
  provider              = azurerm.SHAREDSERVICESSub  
  name                  = var.InfoAssistINTSubnetName
  virtual_network_name  = data.azurerm_virtual_network.InfoAssistVNet.name
  resource_group_name   = var.InfoAssistResourceGroupName
}

data "azurerm_network_security_group" "InfoAssistNSG" {
  provider            = azurerm.SHAREDSERVICESSub  
  name                = var.InfoAssistNSGName
  resource_group_name = var.InfoAssistResourceGroupName
}

data "azurerm_private_dns_zone" "AzureAutomationPDZ" {
  provider            = azurerm.HUBSub
  name                = "privatelink.${var.azure_automation_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "AzureCRPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_acr_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "AzureWebPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_websites_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "BlobStoragePDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_blob_storage_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "FileStoragePDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_file_storage_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "QueueStoragePDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_queue_storage_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "TableStoragePDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_table_storage_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "CognitiveServicesPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_ai_document_intelligence_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "DocumentsPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.cosmosdb_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "MonitorPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_monitor_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "MonitorODSPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_monitor_ods_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "MonitorOMSPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_monitor_oms_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "OpenAIPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_openai_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "SearchServicePDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_search_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_private_dns_zone" "KeyVaultPDZ" {
  provider            = azurerm.HUBSub  
  name                = "privatelink.${var.azure_keyvault_domain}"
  resource_group_name = var.AZPDZResourceGroupName
}

data "azurerm_key_vault" "InfoAssistKeyVault" {
  provider              = azurerm.HUBSub    
  name                  = var.KVName
  resource_group_name   = var.KVResourceGroupName
}

module "logging" {
  source = "./core/logging/loganalytics"
  ResourceNamingConvention = var.ResourceNamingConvention
  location                = var.location
  tags                    = local.tags
  skuName                 = "PerGB2018"
  InfoAssistResourceGroupName           = var.InfoAssistResourceGroupName
  APDZResourceGroupName                 = var.AZPDZResourceGroupName
  is_secure_mode                        = var.is_secure_mode
  privateDnsZoneNameMonitor             = "privatelink.${var.azure_monitor_domain}"
  privateDnsZoneNameOms                 = "privatelink.${var.azure_monitor_oms_domain}"
  privateDnSZoneNameOds                 = "privatelink.${var.azure_monitor_ods_domain}"
  privateDnsZoneNameAutomation          = "privatelink.${var.azure_automation_domain}"
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