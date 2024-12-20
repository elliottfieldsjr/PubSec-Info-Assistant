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
    azurerm.HUBSub = azurerm.HUBSub
    azurerm.OPERATIONSSub = azurerm.OPERATIONSSub
  }  
  location                = var.location
  tags                    = local.tags
  skuName                 = "PerGB2018"
  InfoAssistResourceGroupName           = var.InfoAssistResourceGroupName
  APDZResourceGroupName                 = var.APDZResourceGroupName
  LAWResourceGroupName                  = var.LAWResourceGroupName
  LAWName                               = var.LAWName
  AMPLSName                             = var.AMPLSName
  AppInsightsName                       = "${var.ResourceNamingConvention}-appinsights"
  AppInsightsAMPLSName                  = "${var.ResourceNamingConvention}-ampls-appinsights-connection"
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

module "azMonitor" {
  source            = "./core/logging/monitor"
  providers = {
    azurerm = azurerm
    azurerm.OPERATIONSSub = azurerm.OPERATIONSSub
  }   
  logAnalyticsName  = data.azurerm_log_analytics_workspace.ExistingLAW.name
  location          = var.location
  logWorkbookName   = "${var.ResourceNamingConvention}-lw-va"
  resourceGroupName = var.LAWResourceGroupName
  componentResource = "/subscriptions/${data.azurerm_client_config.OperationsSub.subscription_id}/resourceGroups/${var.LAWResourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/${data.azurerm_log_analytics_workspace.ExistingLAW.name}"
}

module "storage" {
  source                          = "./core/storage"
  providers = {
    azurerm = azurerm
    azurerm.HUBSub = azurerm.HUBSub
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

module "acr"{ 
  source                = "./core/container_registry"
  CloudShellIP          = var.CloudShellIP  
  name                  = "${var.ResourceNamingConvention}datacrva" 
  location              = var.location
  resourceGroupName     = var.InfoAssistResourceGroupName
  is_secure_mode        = var.is_secure_mode
  subnet_name           = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  vnet_name             = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_name = var.is_secure_mode ? data.azurerm_private_dns_zone.AzureCRPDZ.name : null
  private_dns_zone_ids  = var.is_secure_mode ? [data.azurerm_private_dns_zone.AzureCRPDZ.id] : null
}

module "openaiServices" {
  source                          = "./core/ai/openaiservices"
  name                            = var.openAIServiceName != "" ? var.openAIServiceName : "${var.ResourceNamingConvention}-aoai-va"
  location                        = var.location
  tags                            = local.tags
  resourceGroupName               = var.InfoAssistResourceGroupName
  useExistingAOAIService          = var.useExistingAOAIService
  is_secure_mode                  = var.is_secure_mode
  subnet_name                     = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name: null
  vnet_name                       = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  subnet_id                       = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.id : null
  private_dns_zone_ids            = var.is_secure_mode ? [data.azurerm_private_dns_zone.OpenAIPDZ.id] : null
  arm_template_schema_mgmt_api    = var.arm_template_schema_mgmt_api
  key_vault_name                  = data.azurerm_key_vault.InfoAssistKeyVault.name
  logAnalyticsWorkspaceResourceId = data.azurerm_log_analytics_workspace.ExistingLAW.id

  deployments = [
    {
      name            = var.chatGptDeploymentName != "" ? var.chatGptDeploymentName : (var.chatGptModelName != "" ? var.chatGptModelName : "gpt-35-turbo-16k")
      model           = {
        format        = "OpenAI"
        name          = var.chatGptModelName != "" ? var.chatGptModelName : "gpt-35-turbo-16k"
        version       = var.chatGptModelVersion != "" ? var.chatGptModelVersion : "0613"
      }
      sku             = {
        name          = var.chatGptModelSkuName
        capacity      = var.chatGptDeploymentCapacity
      }
      rai_policy_name = "Microsoft.Default"
    },
    {
      name            = var.azureOpenAIEmbeddingDeploymentName != "" ? var.azureOpenAIEmbeddingDeploymentName : "text-embedding-ada-002"
      model           = {
        format        = "OpenAI"
        name          = var.azureOpenAIEmbeddingsModelName != "" ? var.azureOpenAIEmbeddingsModelName : "text-embedding-ada-002"
        version       = "2"
      }
      sku             = {
        name          = var.azureOpenAIEmbeddingsModelSku
        capacity      = var.embeddingsDeploymentCapacity
      }
      rai_policy_name = "Microsoft.Default"
    }
  ]
}

module "searchServices" {
  source                        = "./core/search"
  name                          = var.searchServicesName != "" ? var.searchServicesName : "${var.ResourceNamingConvention}-search-va"
  location                      = var.location
  tags                          = local.tags
  semanticSearch                = var.use_semantic_reranker ? "free" : null
  resourceGroupName             = var.InfoAssistResourceGroupName
  azure_search_domain           = var.azure_search_domain
  is_secure_mode                = var.is_secure_mode
  subnet_name                   = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  vnet_name                     = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_ids          = var.is_secure_mode ? [data.azurerm_private_dns_zone.SearchServicePDZ.id] : null
  arm_template_schema_mgmt_api  = var.arm_template_schema_mgmt_api
  key_vault_name                = data.azurerm_key_vault.InfoAssistKeyVault.name
}

module "aiDocIntelligence" {
  source                        = "./core/ai/docintelligence"
  name                          = "${var.ResourceNamingConvention}-docint-va"
  location                      = var.location
  tags                          = local.tags
  customSubDomainName           = "${var.ResourceNamingConvention}-docint-va"
  resourceGroupName             = var.InfoAssistResourceGroupName
  key_vault_name                = data.azurerm_key_vault.InfoAssistKeyVault.name
  is_secure_mode                = var.is_secure_mode
  subnet_name                   = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  vnet_name                     = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_ids          = var.is_secure_mode ? [data.azurerm_private_dns_zone.CognitiveServicesPDZ.id] : null
  arm_template_schema_mgmt_api  = var.arm_template_schema_mgmt_api
}

module "cognitiveServices" { 
  source                        = "./core/ai/cogServices"
  providers = {
    azurerm = azurerm
    azurerm.HUBSub = azurerm.HUBSub
    azurerm.OPERATIONSSub = azurerm.OPERATIONSSub
  }   
  name                          = "${var.ResourceNamingConvention}-aisvc-va"
  location                      = var.location 
  tags                          = local.tags
  InfoAssistResourceGroupName   = var.InfoAssistResourceGroupName
  KVResourceGroupName           = var.KVResourceGroupName 
  is_secure_mode                = var.is_secure_mode
  subnetResourceId              = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.id : null
  private_dns_zone_ids          = var.is_secure_mode ? [data.azurerm_private_dns_zone.CognitiveServicesPDZ.id] : null
  arm_template_schema_mgmt_api  = var.arm_template_schema_mgmt_api
  key_vault_name                = data.azurerm_key_vault.InfoAssistKeyVault.name
  kv_secret_expiration          = var.kv_secret_expiration
  vnet_name                     = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  subnet_name                   = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
}

module "cosmosdb" {  
  source = "./core/db"
  name                          = "${var.ResourceNamingConvention}-cosmos"
  location                      = var.location
  tags                          = local.tags
  logDatabaseName               = "statusdb"
  logContainerName              = "statuscontainer"
  resourceGroupName             = var.InfoAssistResourceGroupName
  key_vault_name                = data.azurerm_key_vault.InfoAssistKeyVault.name
  is_secure_mode                = var.is_secure_mode  
  subnet_name                   = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  vnet_name                     = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_ids          = var.is_secure_mode ? [data.azurerm_private_dns_zone.DocumentsPDZ.id] : null
  arm_template_schema_mgmt_api  = var.arm_template_schema_mgmt_api
}

// SharePoint Connector is not supported in secure mode
module "sharepoint" {
  count                               = var.is_secure_mode ? 0 : var.enableSharePointConnector ? 1 : 0
  source                              = "./core/sharepoint"
  WorkFlowName                        = "${var.ResourceNamingConvention}-infoasst-sharepointonline" 
  location                            = data.azurerm_resource_group.InfoAssistRG.location
  resource_group_name                 = var.InfoAssistResourceGroupName
  resource_group_id                   = data.azurerm_resource_group.InfoAssistRG.name
  subscription_id                     = data.azurerm_client_config.HubSub.subscription_id
  storage_account_name                = module.storage.name
  storage_access_key                  = module.storage.storage_account_access_key
  tags                                = local.tags

  depends_on = [
    module.storage
  ]
}

// Bing Search is not supported in US Government or Secure Mode
module "bingSearch" {  
  providers = {
    azurerm = azurerm
    azurerm.HUBSub = azurerm.HUBSub
    azurerm.OPERATIONSSub = azurerm.OPERATIONSSub
  }
  count                         = var.azure_environment == "AzureUSGovernment" ? 0 : var.is_secure_mode ? 0 : var.enableWebChat ? 1 : 0
  source                        = "./core/ai/bingSearch"
  name                          = "${var.ResourceNamingConvention}-bing-va"
  InfoAssistResourceGroupName   = var.InfoAssistResourceGroupName
  KVResourceGroupName           = var.KVResourceGroupName 
  tags                          = local.tags
  sku                           = "S1" //supported SKUs can be found at https://www.microsoft.com/en-us/bing/apis/pricing
  arm_template_schema_mgmt_api  = var.arm_template_schema_mgmt_api
  key_vault_name                = data.azurerm_key_vault.InfoAssistKeyVault.name
  kv_secret_expiration          = var.kv_secret_expiration
}

module "enrichmentApp" {
  providers = {
    azurerm = azurerm
    azurerm.HUBSub = azurerm.HUBSub
  }     
  source                                    = "./core/host/enrichmentapp"
  name                                      = var.enrichmentServiceName != "" ? var.enrichmentServiceName : "${var.ResourceNamingConvention}-enrichmentweb-va"
  plan_name                                 = var.enrichmentAppServicePlanName != "" ? var.enrichmentAppServicePlanName : "${var.ResourceNamingConvention}-enrichmentasp-va"
  location                                  = var.location 
  tags                                      = local.tags
  sku = {
    size                                    = var.enrichmentAppServiceSkuSize
    tier                                    = var.enrichmentAppServiceSkuTier
    capacity                                = 3
  }
  kind                                      = "linux"
  reserved                                  = true
  InfoAssistResourceGroupName               = var.InfoAssistResourceGroupName
  KVResourceGroupName                       = var.KVResourceGroupName  
  storageAccountId                          = "/subscriptions/${data.azurerm_client_config.SharedServicesSub.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.Storage/storageAccounts/${module.storage.name}/services/queue/queues/${var.embeddingsQueue}"
  scmDoBuildDuringDeployment                = false
  enableOryxBuild                           = false
  managedIdentity                           = true
  logAnalyticsWorkspaceResourceId           = data.azurerm_log_analytics_workspace.ExistingLAW.id
  applicationInsightsConnectionString       = module.logging.applicationInsightsConnectionString
  alwaysOn                                  = true
  healthCheckPath                           = "/health"
  appCommandLine                            = ""
  keyVaultUri                               = data.azurerm_key_vault.InfoAssistKeyVault.vault_uri
  keyVaultName                              = data.azurerm_key_vault.InfoAssistKeyVault.name
  container_registry                        = module.acr.login_server
  container_registry_admin_username         = module.acr.admin_username
  container_registry_admin_password         = module.acr.admin_password
  container_registry_id                     = module.acr.acr_id
  is_secure_mode                            = var.is_secure_mode
  IntegrationSubnetName                     = var.is_secure_mode ? data.azurerm_subnet.InfoAssistINTSubnet.name : null
  PrivateEndpointSubnetName                 = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  vnet_name                                 = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_ids                      = var.is_secure_mode ? [data.azurerm_private_dns_zone.AzureWebPDZ.id] : null
  azure_environment                         = var.azure_environment

  appSettings = {
    EMBEDDINGS_QUEUE                        = var.embeddingsQueue
    LOG_LEVEL                               = "DEBUG"
    DEQUEUE_MESSAGE_BATCH_SIZE              = 1
    AZURE_BLOB_STORAGE_ACCOUNT              = module.storage.name
    AZURE_BLOB_STORAGE_CONTAINER            = var.contentContainerName
    AZURE_BLOB_STORAGE_UPLOAD_CONTAINER     = var.uploadContainerName
    AZURE_BLOB_STORAGE_ENDPOINT             = module.storage.primary_blob_endpoint
    AZURE_QUEUE_STORAGE_ENDPOINT            = module.storage.primary_queue_endpoint
    COSMOSDB_URL                            = module.cosmosdb.CosmosDBEndpointURL
    COSMOSDB_LOG_DATABASE_NAME              = module.cosmosdb.CosmosDBLogDatabaseName
    COSMOSDB_LOG_CONTAINER_NAME             = module.cosmosdb.CosmosDBLogContainerName
    MAX_EMBEDDING_REQUEUE_COUNT             = 5
    EMBEDDING_REQUEUE_BACKOFF               = 60
    AZURE_OPENAI_SERVICE                    = var.useExistingAOAIService ? var.azureOpenAIServiceName : module.openaiServices.name
    AZURE_OPENAI_ENDPOINT                   = var.useExistingAOAIService ? "https://${var.azureOpenAIServiceName}.${var.azure_openai_domain}/" : module.openaiServices.endpoint
    AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME  = var.azureOpenAIEmbeddingDeploymentName
    AZURE_SEARCH_INDEX                      = var.searchIndexName
    AZURE_SEARCH_SERVICE_ENDPOINT           = module.searchServices.endpoint
    AZURE_SEARCH_AUDIENCE                   = var.azure_search_scope
    TARGET_EMBEDDINGS_MODEL                 = var.useAzureOpenAIEmbeddings ? "azure-openai_${var.azureOpenAIEmbeddingDeploymentName}" : var.sentenceTransformersModelName
    EMBEDDING_VECTOR_SIZE                   = var.useAzureOpenAIEmbeddings ? 1536 : var.sentenceTransformerEmbeddingVectorSize
    AZURE_AI_CREDENTIAL_DOMAIN              = var.azure_ai_private_link_domain
    AZURE_OPENAI_AUTHORITY_HOST             = var.azure_openai_authority_host
  }
}

# // The application frontend
module "webapp" {
  providers = {
    azurerm = azurerm
    azurerm.HUBSub = azurerm.HUBSub
  }   
  source                              = "./core/host/webapp"
  name                                = var.backendServiceName != "" ? var.backendServiceName : "${var.ResourceNamingConvention}-web-va"
  plan_name                           = var.appServicePlanName != "" ? var.appServicePlanName : "${var.ResourceNamingConvention}-asp-va"
  sku = {
    tier                              = var.appServiceSkuTier
    size                              = var.appServiceSkuSize
    capacity                          = 1
  }
  kind                                = "linux"
  InfoAssistResourceGroupName         = var.InfoAssistResourceGroupName
  KVResourceGroupName                 = var.KVResourceGroupName 
  location                            = var.location
  tags                                = merge(local.tags, { "azd-service-name" = "backend" })
  runtimeVersion                      = "3.12" 
  scmDoBuildDuringDeployment          = false
  managedIdentity                     = true
  alwaysOn                            = true
  appCommandLine                      = ""
  healthCheckPath                     = "/health"
  logAnalyticsWorkspaceResourceId     = data.azurerm_log_analytics_workspace.ExistingLAW.id
  azure_portal_domain                 = var.azure_portal_domain
  enableOryxBuild                     = false
  applicationInsightsConnectionString = module.logging.applicationInsightsConnectionString
  keyVaultUri                         = data.azurerm_key_vault.InfoAssistKeyVault.vault_uri
  keyVaultName                        = data.azurerm_key_vault.InfoAssistKeyVault.name
  tenantId                            = data.azurerm_client_config.SharedServicesSub.tenant_id
  is_secure_mode                      = var.is_secure_mode
  IntegrationSubnetName               = var.is_secure_mode ? data.azurerm_subnet.InfoAssistINTSubnet.name : null
  PrivateEndpointSubnetName           = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  vnet_name                           = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_ids                = var.is_secure_mode ? [data.azurerm_private_dns_zone.AzureWebPDZ.id] : null
  private_dns_zone_name               = var.is_secure_mode ? data.azurerm_private_dns_zone.AzureWebPDZ.name : null

  container_registry                  = module.acr.login_server
  container_registry_admin_username   = module.acr.admin_username
  container_registry_admin_password   = module.acr.admin_password
  container_registry_id               = module.acr.acr_id
  azure_environment                   = var.azure_environment 

  appSettings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING   = module.logging.applicationInsightsConnectionString
    AZURE_BLOB_STORAGE_ACCOUNT              = module.storage.name
    AZURE_BLOB_STORAGE_ENDPOINT             = module.storage.primary_blob_endpoint
    AZURE_BLOB_STORAGE_CONTAINER            = var.contentContainerName
    AZURE_BLOB_STORAGE_UPLOAD_CONTAINER     = var.uploadContainerName
    AZURE_OPENAI_SERVICE                    = var.useExistingAOAIService ? var.azureOpenAIServiceName : module.openaiServices.name
    AZURE_OPENAI_RESOURCE_GROUP             = var.useExistingAOAIService ? var.azureOpenAIResourceGroup : var.InfoAssistResourceGroupName
    AZURE_OPENAI_ENDPOINT                   = var.useExistingAOAIService ? "https://${var.azureOpenAIServiceName}.${var.azure_openai_domain}/" : module.openaiServices.endpoint
    AZURE_OPENAI_AUTHORITY_HOST             = var.azure_openai_authority_host
    AZURE_ARM_MANAGEMENT_API                = var.azure_arm_management_api
    AZURE_SEARCH_INDEX                      = var.searchIndexName
    AZURE_SEARCH_SERVICE                    = module.searchServices.name
    AZURE_SEARCH_SERVICE_ENDPOINT           = module.searchServices.endpoint
    AZURE_SEARCH_AUDIENCE                   = var.azure_search_scope
    AZURE_OPENAI_CHATGPT_DEPLOYMENT         = var.chatGptDeploymentName != "" ? var.chatGptDeploymentName : (var.chatGptModelName != "" ? var.chatGptModelName : "gpt-35-turbo-16k")
    AZURE_OPENAI_CHATGPT_MODEL_NAME         = var.chatGptModelName
    AZURE_OPENAI_CHATGPT_MODEL_VERSION      = var.chatGptModelVersion
    USE_AZURE_OPENAI_EMBEDDINGS             = var.useAzureOpenAIEmbeddings
    EMBEDDING_DEPLOYMENT_NAME               = var.useAzureOpenAIEmbeddings ? var.azureOpenAIEmbeddingDeploymentName : var.sentenceTransformersModelName
    AZURE_OPENAI_EMBEDDINGS_MODEL_NAME      = var.azureOpenAIEmbeddingsModelName
    AZURE_OPENAI_EMBEDDINGS_MODEL_VERSION   = var.azureOpenAIEmbeddingsModelVersion
    APPINSIGHTS_INSTRUMENTATIONKEY          = module.logging.applicationInsightsInstrumentationKey
    COSMOSDB_URL                            = module.cosmosdb.CosmosDBEndpointURL
    COSMOSDB_LOG_DATABASE_NAME              = module.cosmosdb.CosmosDBLogDatabaseName
    COSMOSDB_LOG_CONTAINER_NAME             = module.cosmosdb.CosmosDBLogContainerName
    QUERY_TERM_LANGUAGE                     = var.queryTermLanguage
    AZURE_SUBSCRIPTION_ID                   = data.azurerm_client_config.SharedServicesSub.subscription_id
    CHAT_WARNING_BANNER_TEXT                = var.chatWarningBannerText
    TARGET_EMBEDDINGS_MODEL                 = var.useAzureOpenAIEmbeddings ? "azure-openai_${var.azureOpenAIEmbeddingDeploymentName}" : var.sentenceTransformersModelName
    ENRICHMENT_APPSERVICE_URL               = module.enrichmentApp.uri
    AZURE_AI_ENDPOINT                       = module.cognitiveServices.cognitiveServiceEndpoint
    AZURE_AI_LOCATION                       = var.location
    APPLICATION_TITLE                       = var.applicationtitle == "" ? "Information Assistant, built with Azure OpenAI" : var.applicationtitle
    USE_SEMANTIC_RERANKER                   = var.use_semantic_reranker
    BING_SEARCH_ENDPOINT                    = var.enableWebChat ? module.bingSearch[0].endpoint : ""
    ENABLE_WEB_CHAT                         = var.enableWebChat
    ENABLE_BING_SAFE_SEARCH                 = var.enableBingSafeSearch
    ENABLE_UNGROUNDED_CHAT                  = var.enableUngroundedChat
    ENABLE_MATH_ASSISTANT                   = var.enableMathAssitant
    ENABLE_TABULAR_DATA_ASSISTANT           = var.enableTabularDataAssistant
    MAX_CSV_FILE_SIZE                       = var.maxCsvFileSize
    AZURE_AI_CREDENTIAL_DOMAIN               = var.azure_ai_private_link_domain
  }

  aadClientId = module.entraObjects.azure_ad_web_app_client_id
  depends_on = [ data.azurerm_key_vault.InfoAssistKeyVault]
}


# // Function App 
module "functions" { 
  providers = {
    azurerm = azurerm
    azurerm.HUBSub = azurerm.HUBSub
  }
  source = "./core/host/functions"  
  name                                  = var.functionsAppName != "" ? var.functionsAppName : "${var.ResourceNamingConvention}-func-va"
  location                              = var.location
  tags                                  = local.tags
  keyVaultUri                           = data.azurerm_key_vault.InfoAssistKeyVault.vault_uri
  keyVaultName                          = data.azurerm_key_vault.InfoAssistKeyVault.name
  plan_name                             = var.appServicePlanName != "" ? var.appServicePlanName : "${var.ResourceNamingConvention}-func-asp-va"
  sku                                   = {
    size                                = var.functionsAppSkuSize
    tier                                = var.functionsAppSkuTier
    capacity                            = 2
  }
  kind                                  = "linux"
  runtime                               = "python"
  InfoAssistResourceGroupName           = var.InfoAssistResourceGroupName
  KVResourceGroupName                   = var.KVResourceGroupName 
  azure_portal_domain                   = var.azure_portal_domain
  appInsightsConnectionString           = module.logging.applicationInsightsConnectionString
  appInsightsInstrumentationKey         = module.logging.applicationInsightsInstrumentationKey
  blobStorageAccountName                = module.storage.name
  blobStorageAccountEndpoint            = module.storage.primary_blob_endpoint
  blobStorageAccountOutputContainerName = var.contentContainerName
  blobStorageAccountUploadContainerName = var.uploadContainerName 
  blobStorageAccountLogContainerName    = var.functionLogsContainerName
  queueStorageAccountEndpoint           = module.storage.primary_queue_endpoint
  formRecognizerEndpoint                = module.aiDocIntelligence.formRecognizerAccountEndpoint
  CosmosDBEndpointURL                   = module.cosmosdb.CosmosDBEndpointURL
  CosmosDBLogDatabaseName               = module.cosmosdb.CosmosDBLogDatabaseName
  CosmosDBLogContainerName              = module.cosmosdb.CosmosDBLogContainerName
  chunkTargetSize                       = var.chunkTargetSize
  targetPages                           = var.targetPages
  formRecognizerApiVersion              = var.formRecognizerApiVersion
  pdfSubmitQueue                        = var.pdfSubmitQueue
  pdfPollingQueue                       = var.pdfPollingQueue
  nonPdfSubmitQueue                     = var.nonPdfSubmitQueue
  mediaSubmitQueue                      = var.mediaSubmitQueue
  maxSecondsHideOnUpload                = var.maxSecondsHideOnUpload
  maxSubmitRequeueCount                 = var.maxSubmitRequeueCount
  pollQueueSubmitBackoff                = var.pollQueueSubmitBackoff
  pdfSubmitQueueBackoff                 = var.pdfSubmitQueueBackoff
  textEnrichmentQueue                   = var.textEnrichmentQueue
  imageEnrichmentQueue                  = var.imageEnrichmentQueue
  maxPollingRequeueCount                = var.maxPollingRequeueCount
  submitRequeueHideSeconds              = var.submitRequeueHideSeconds
  pollingBackoff                        = var.pollingBackoff
  maxReadAttempts                       = var.maxReadAttempts
  enrichmentEndpoint                    = module.cognitiveServices.cognitiveServiceEndpoint
  enrichmentName                        = module.cognitiveServices.cognitiveServicerAccountName
  enrichmentLocation                    = var.location
  targetTranslationLanguage             = var.targetTranslationLanguage
  maxEnrichmentRequeueCount             = var.maxEnrichmentRequeueCount
  enrichmentBackoff                     = var.enrichmentBackoff
  enableDevCode                         = var.enableDevCode
  EMBEDDINGS_QUEUE                      = var.embeddingsQueue
  azureSearchIndex                      = var.searchIndexName
  azureSearchServiceEndpoint            = module.searchServices.endpoint
  endpointSuffix                        = var.azure_storage_domain
  logAnalyticsWorkspaceResourceId       = data.azurerm_log_analytics_workspace.ExistingLAW.id
  is_secure_mode                        = var.is_secure_mode
  vnet_name                             = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  IntegrationSubnetName                 = var.is_secure_mode ? data.azurerm_subnet.InfoAssistINTSubnet.name : null
  PrivateEndpointSubnetName             = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  private_dns_zone_ids                  = var.is_secure_mode ? [data.azurerm_private_dns_zone.AzureWebPDZ.id] : null
  container_registry                    = module.acr.login_server
  container_registry_admin_username     = module.acr.admin_username
  container_registry_admin_password     = module.acr.admin_password
  container_registry_id                 = module.acr.acr_id
  azure_environment                     = var.azure_environment
  azure_ai_credential_domain            = var.azure_ai_private_link_domain
}

// USER ROLES
module "userRoles" { 
  source = "./core/security/role"
  for_each = { for role in local.selected_roles : role => { role_definition_id = local.azure_roles[role] } }

  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = data.azurerm_client_config.SharedServicesSub.object_id
  roleDefinitionId = each.value.role_definition_id
  principalType    = var.isInAutomation ? "ServicePrincipal" : "User"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "user_cosmosdb_data_contributor" {
  resource_group_name = var.InfoAssistResourceGroupName
  account_name = module.cosmosdb.name
  role_definition_id = "/subscriptions/${data.azurerm_client_config.SharedServicesSub.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${module.cosmosdb.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002" #Cosmos DB Built-in Data Contributor
  principal_id = data.azurerm_client_config.SharedServicesSub.object_id
  scope = module.cosmosdb.id
}

data "azurerm_resource_group" "existing" {
  count = var.useExistingAOAIService ? 1 : 0
  name  = var.azureOpenAIResourceGroup
}

# # // SYSTEM IDENTITY ROLES
module "webApp_OpenAiRole" { 
  source = "./core/security/role"
  scope            = var.useExistingAOAIService ? data.azurerm_resource_group.existing[0].id : data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.webapp.identityPrincipalId
  roleDefinitionId = local.azure_roles.CognitiveServicesOpenAIUser
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "enrichmentApp_OpenAiRole" {
  source = "./core/security/role"
  scope            = var.useExistingAOAIService ? data.azurerm_resource_group.existing[0].id : data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.enrichmentApp.identityPrincipalId
  roleDefinitionId = local.azure_roles.CognitiveServicesOpenAIUser
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "webApp_CognitiveServicesUser" {
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.webapp.identityPrincipalId
  roleDefinitionId = local.azure_roles.CognitiveServicesUser
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "functionApp_CognitiveServicesUser" {
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.functions.identityPrincipalId
  roleDefinitionId = local.azure_roles.CognitiveServicesUser
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "enrichmentApp_CognitiveServicesUser" { 
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.enrichmentApp.identityPrincipalId
  roleDefinitionId = local.azure_roles.CognitiveServicesUser
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "enrichmentApp_StorageQueueDataContributor" {
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.enrichmentApp.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageQueueDataContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "functionApp_StorageQueueDataContributor" { 
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.functions.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageQueueDataContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "webApp_StorageBlobDataContributor" {
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.webapp.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageBlobDataContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "webApp_SearchIndexDataReader" {
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.webapp.identityPrincipalId
  roleDefinitionId = local.azure_roles.SearchIndexDataReader
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "functionApp_SearchIndexDataContributor" {
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.functions.identityPrincipalId
  roleDefinitionId = local.azure_roles.SearchIndexDataContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "encrichmentApp_SearchIndexDataContributor" {
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.enrichmentApp.identityPrincipalId
  roleDefinitionId = local.azure_roles.SearchIndexDataContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "fuctionApp_StorageBlobDataOwner" {
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.functions.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageBlobDataOwner
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "enrichmentApp_StorageBlobDataOwner" {
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.enrichmentApp.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageBlobDataOwner
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "fuctionApp_StorageAccountContributor" { 
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.functions.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageAccountContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.SharedServicesSub.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "webApp_cosmosdb_data_contributor" {
  resource_group_name = var.InfoAssistResourceGroupName
  account_name = module.cosmosdb.name
  role_definition_id = "/subscriptions/${data.azurerm_client_config.SharedServicesSub.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${module.cosmosdb.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002" #Cosmos DB Built-in Data Contributor
  principal_id = module.webapp.identityPrincipalId
  scope = module.cosmosdb.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "functionApp_cosmosdb_data_contributor" {
  resource_group_name = var.InfoAssistResourceGroupName
  account_name = module.cosmosdb.name
  role_definition_id = "/subscriptions/${data.azurerm_client_config.SharedServicesSub.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${module.cosmosdb.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002" #Cosmos DB Built-in Data Contributor
  principal_id = module.functions.identityPrincipalId
  scope = module.cosmosdb.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "enrichmentApp_cosmosdb_data_contributor" {
  resource_group_name = var.InfoAssistResourceGroupName
  account_name = module.cosmosdb.name
  role_definition_id = "/subscriptions/${data.azurerm_client_config.SharedServicesSub.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${module.cosmosdb.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002" #Cosmos DB Built-in Data Contributor
  principal_id = module.enrichmentApp.identityPrincipalId
  scope = module.cosmosdb.id
}
