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

data "azurerm" "HUB" {
  provider = azurerm.HUBSub
}

data "azurerm" "IDENTITY" {
  provider = azurerm.IDENTITYSub
}

data "azurerm" "OPERATIONS" {
  provider = azurerm.OPERATIONSSub
}

data "azurerm" "SHAREDSERVICES" {
  provider = azurerm.SHAREDSERVICESSub
}

module "logging" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/logging/loganalytics"
  logAnalyticsName        = var.logAnalyticsName != "" ? var.logAnalyticsName : "dat-la-${random_string.random.result}"
  applicationInsightsName = var.applicationInsightsName != "" ? var.applicationInsightsName : "dat-ai-${random_string.random.result}"
  location                = var.location
  tags                    = local.tags
  skuName                 = "PerGB2018"
  resourceGroupName       = var.InfoAssistResourceGroupName
  is_secure_mode                        = var.is_secure_mode
  privateLinkScopeName                  = "dat-ampls-${random_string.random.result}"
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

module "storage" {
  Provider = data.azurerm.SHAREDSERVICES
  source                          = "./core/storage"
  CloudShellIP                    = var.CloudShellIP
  name                            = var.storageAccountName != "" ? var.storageAccountName : "datstore${random_string.random.result}"
  location                        = var.location
  tags                            = local.tags
  accessTier                      = "Hot"
  allowBlobPublicAccess           = false
  resourceGroupName               = var.InfoAssistResourceGroupName
  arm_template_schema_mgmt_api    = var.arm_template_schema_mgmt_api
  key_vault_name                  = var.KVName
  deleteRetentionPolicy = {
    days                          = 7
  }
  containers                      = ["content","website","upload","function","logs","config"]
  queueNames                      = ["pdf-submit-queue","pdf-polling-queue","non-pdf-submit-queue","media-submit-queue","text-enrichment-queue","image-enrichment-queue","embeddings-queue"]
  is_secure_mode                  = var.is_secure_mode
  subnet_name                     = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.id : null
  vnet_name                       = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_ids            = var.is_secure_mode ? [data.azurerm_private_dns_zone.BlobStoragePDZ.id,
                                       data.azurerm_private_dns_zone.FileStoragePDZ.id,
                                        data.azurerm_private_dns_zone.TableStoragePDZ.id,
                                        data.azurerm_private_dns_zone.QueueStoragePDZ.id] : null
  network_rules_allowed_subnets   = var.is_secure_mode ? [data.azurerm_subnet.InfoAssistPESubnet.id] : null
  kv_secret_expiration            = var.kv_secret_expiration
  logAnalyticsWorkspaceResourceId = module.logging.logAnalyticsId
}

module "enrichmentApp" {
  Provider = data.azurerm.SHAREDSERVICES
  source                                    = "./core/host/enrichmentapp"
  name                                      = var.enrichmentServiceName != "" ? var.enrichmentServiceName : "dat-enrichmentweb-${random_string.random.result}"
  plan_name                                 = var.enrichmentAppServicePlanName != "" ? var.enrichmentAppServicePlanName : "dat-enrichmentasp-${random_string.random.result}"
  location                                  = var.location 
  tags                                      = local.tags
  sku = {
    size                                    = var.enrichmentAppServiceSkuSize
    tier                                    = var.enrichmentAppServiceSkuTier
    capacity                                = 3
  }
  kind                                      = "linux"
  reserved                                  = true
  resourceGroupName                         = var.InfoAssistResourceGroupName
  storageAccountId                          = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.Storage/storageAccounts/${module.storage.name}/services/queue/queues/${var.embeddingsQueue}"
  scmDoBuildDuringDeployment                = false
  enableOryxBuild                           = false
  managedIdentity                           = true
  logAnalyticsWorkspaceResourceId           = module.logging.logAnalyticsId
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
  subnetIntegration_id                      = var.is_secure_mode ? data.azurerm_subnet.InfoAssistINTSubnet.id : null
  subnet_name                               = var.is_secure_mode ? data.azurerm_subnet.InfoAssistINTSubnet.name : null
  vnet_name                                 = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_ids                      = var.is_secure_mode ? [data.azurerm_private_dns_zone.id] : null
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
  Provider = data.azurerm.SHAREDSERVICES
  source                              = "./core/host/webapp"
  name                                = var.backendServiceName != "" ? var.backendServiceName : "dat-web-${random_string.random.result}"
  plan_name                           = var.appServicePlanName != "" ? var.appServicePlanName : "dat-asp-${random_string.random.result}"
  sku = {
    tier                              = var.appServiceSkuTier
    size                              = var.appServiceSkuSize
    capacity                          = 1
  }
  kind                                = "linux"
  resourceGroupName                   = var.InfoAssistResourceGroupName.name
  location                            = var.location
  tags                                = merge(local.tags, { "azd-service-name" = "backend" })
  runtimeVersion                      = "3.12" 
  scmDoBuildDuringDeployment          = false
  managedIdentity                     = true
  alwaysOn                            = true
  appCommandLine                      = ""
  healthCheckPath                     = "/health"
  logAnalyticsWorkspaceResourceId     = module.logging.logAnalyticsId
  azure_portal_domain                 = var.azure_portal_domain
  enableOryxBuild                     = false
  applicationInsightsConnectionString = module.logging.applicationInsightsConnectionString
  keyVaultUri                         = data.azurerm_key_vault.InfoAssistKeyVault.vault_uri
  keyVaultName                        = data.azurerm_key_vault.InfoAssistKeyVault.name
  tenantId                            = data.azurerm_client_config.current.tenant_id
  is_secure_mode                      = var.is_secure_mode
  subnet_name                         = var.is_secure_mode ? data.azurerm_subnet.InfoAssistINTSubnet.name: null
  vnet_name                           = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  snetIntegration_id                  = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.id: null
  private_dns_zone_ids                = var.is_secure_mode ? [data.azurerm_private_dns_zone.AzureWebPDZ.id] : null
  private_dns_zone_name               = var.is_secure_mode ? data.azurerm_private_dns_zone.AzureWebPDZ.name : null

  container_registry                  = module.acr.login_server
  container_registry_admin_username   = module.acr.admin_username
  container_registry_admin_password   = module.acr.admin_password
  container_registry_id               = module.acr.acr_id
  randomString                        = random_string.random.result
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
    AZURE_SUBSCRIPTION_ID                   = data.azurerm_client_config.current.subscription_id
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
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/host/functions"
  name                                  = var.functionsAppName != "" ? var.functionsAppName : "dat-func-${random_string.random.result}"
  location                              = var.location
  tags                                  = local.tags
  keyVaultUri                           = data.azurerm_key_vault.InfoAssistKeyVault.vault_uri
  keyVaultName                          = data.azurerm_key_vault.InfoAssistKeyVault.name
  plan_name                             = var.appServicePlanName != "" ? var.appServicePlanName : "dat-func-asp-${random_string.random.result}"
  sku                                   = {
    size                                = var.functionsAppSkuSize
    tier                                = var.functionsAppSkuTier
    capacity                            = 2
  }
  kind                                  = "linux"
  runtime                               = "python"
  resourceGroupName                     = var.InfoAssistResourceGroupName
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
  logAnalyticsWorkspaceResourceId       = module.logging.logAnalyticsId
  is_secure_mode                        = var.is_secure_mode
  vnet_name                             = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  subnet_name                           = var.is_secure_mode ? data.azurerm_subnet.InfoAssistINTSubnet.name : null
  subnetIntegration_id                  = var.is_secure_mode ? data.azurerm_subnet.InfoAssistINTSubnet.id : null
  private_dns_zone_ids                  = var.is_secure_mode ? [data.azurerm_private_dns_zone.AzureWebPDZ.id] : null
  container_registry                    = module.acr.login_server
  container_registry_admin_username     = module.acr.admin_username
  container_registry_admin_password     = module.acr.admin_password
  container_registry_id                 = module.acr.acr_id
  azure_environment                     = var.azure_environment
  azure_ai_credential_domain            = var.azure_ai_private_link_domain
}

module "openaiServices" {
  Provider = data.azurerm.SHAREDSERVICES
  source                          = "./core/ai/openaiservices"
  name                            = var.openAIServiceName != "" ? var.openAIServiceName : "dat-aoai-${random_string.random.result}"
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
  logAnalyticsWorkspaceResourceId = module.logging.logAnalyticsId

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

module "aiDocIntelligence" {
  Provider = data.azurerm.SHAREDSERVICES
  source                        = "./core/ai/docintelligence"
  name                          = "dat-docint-${random_string.random.result}"
  location                      = var.location
  tags                          = local.tags
  customSubDomainName           = "dat-docint-${random_string.random.result}"
  resourceGroupName             = var.InfoAssistResourceGroupName
  key_vault_name                = data.azurerm_key_vault.InfoAssistKeyVault.name
  is_secure_mode                = var.is_secure_mode
  subnet_name                   = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  vnet_name                     = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_ids          = var.is_secure_mode ? [data.azurerm_private_dns_zone.CognitiveServicesPDZ.id] : null
  arm_template_schema_mgmt_api  = var.arm_template_schema_mgmt_api
}

module "cognitiveServices" {
  Provider = data.azurerm.SHAREDSERVICES
  source                        = "./core/ai/cogServices"
  name                          = "dat-aisvc-${random_string.random.result}"
  location                      = var.location 
  tags                          = local.tags
  resourceGroupName             = var.InfoAssistResourceGroupName
  is_secure_mode                = var.is_secure_mode
  subnetResourceId              = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.id : null
  private_dns_zone_ids          = var.is_secure_mode ? [data.azurerm_private_dns_zone.CognitiveServicesPDZ.id] : null
  arm_template_schema_mgmt_api  = var.arm_template_schema_mgmt_api
  key_vault_name                = data.azurerm_key_vault.InfoAssistKeyVault.name
  kv_secret_expiration          = var.kv_secret_expiration
  vnet_name                     = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  subnet_name                   = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
}

module "searchServices" {
  Provider = data.azurerm.SHAREDSERVICES
  source                        = "./core/search"
  name                          = var.searchServicesName != "" ? var.searchServicesName : "dat-search-${random_string.random.result}"
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

module "cosmosdb" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/db"
  name                          = "dat-cosmos-${random_string.random.result}"
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

module "acr"{
  Provider = data.azurerm.SHAREDSERVICES
  source                = "./core/container_registry"
  CloudShellIP                    = var.CloudShellIP  
  name                  = "datacr${random_string.random.result}" 
  location              = var.location
  resourceGroupName     = var.InfoAssistResourceGroupName
  is_secure_mode        = var.is_secure_mode
  subnet_name           = var.is_secure_mode ? data.azurerm_subnet.InfoAssistPESubnet.name : null
  vnet_name             = var.is_secure_mode ? data.azurerm_virtual_network.InfoAssistVNet.name : null
  private_dns_zone_name = var.is_secure_mode ? data.azurerm_private_dns_zone.AzureCRPDZ.name : null
  private_dns_zone_ids  = var.is_secure_mode ? [data.azurerm_private_dns_zone.AzureCRPDZ.id] : null
}

// SharePoint Connector is not supported in secure mode
module "sharepoint" {
  Provider = data.azurerm.SHAREDSERVICES
  count                               = var.is_secure_mode ? 0 : var.enableSharePointConnector ? 1 : 0
  source                              = "./core/sharepoint"
  location                            = data.azurerm_resource_group.InfoAssistRG.location
  resource_group_name                 = var.InfoAssistResourceGroupName
  resource_group_id                   = data.azurerm_resource_group.InfoAssistRG.name
  subscription_id                     = data.azurerm_client_config.current.subscription_id
  storage_account_name                = module.storage.name
  storage_access_key                  = module.storage.storage_account_access_key
  random_string                       = random_string.random.result
  tags                                = local.tags

  depends_on = [
    module.storage
  ]
}

module "azMonitor" {
  Provider = data.azurerm.SHAREDSERVICES  
  source            = "./core/logging/monitor"
  logAnalyticsName  = module.logging.logAnalyticsName
  location          = var.location
  logWorkbookName   = "dat-lw-${random_string.random.result}"
  resourceGroupName = var.InfoAssistResourceGroupName 
  componentResource = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/${module.logging.logAnalyticsName}"
}

// Bing Search is not supported in US Government or Secure Mode
module "bingSearch" {
  Provider = data.azurerm.SHAREDSERVICES
  count                         = var.azure_environment == "AzureUSGovernment" ? 0 : var.is_secure_mode ? 0 : var.enableWebChat ? 1 : 0
  source                        = "./core/ai/bingSearch"
  name                          = "dat-bing-${random_string.random.result}"
  resourceGroupName             = var.InfoAssistResourceGroupName
  tags                          = local.tags
  sku                           = "S1" //supported SKUs can be found at https://www.microsoft.com/en-us/bing/apis/pricing
  arm_template_schema_mgmt_api  = var.arm_template_schema_mgmt_api
  key_vault_name                = data.azurerm_key_vault.InfoAssistKeyVault.name
  kv_secret_expiration          = var.kv_secret_expiration
}

// USER ROLES
module "userRoles" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/security/role"
  for_each = { for role in local.selected_roles : role => { role_definition_id = local.azure_roles[role] } }

  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = data.azurerm_client_config.current.object_id 
  roleDefinitionId = each.value.role_definition_id
  principalType    = var.isInAutomation ? "ServicePrincipal" : "User"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "user_cosmosdb_data_contributor" {
  resource_group_name = var.InfoAssistResourceGroupName
  account_name = module.cosmosdb.name
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${module.cosmosdb.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002" #Cosmos DB Built-in Data Contributor
  principal_id = data.azurerm_client_config.current.object_id
  scope = module.cosmosdb.id
}

data "azurerm_resource_group" "existing" {
  count = var.useExistingAOAIService ? 1 : 0
  name  = var.azureOpenAIResourceGroup
}

# # // SYSTEM IDENTITY ROLES
module "webApp_OpenAiRole" {
  Provider                      = azurrm.HUBSub      
  source = "./core/security/role"
  scope            = var.useExistingAOAIService ? data.azurerm_resource_group.existing[0].id : data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.webapp.identityPrincipalId
  roleDefinitionId = local.azure_roles.CognitiveServicesOpenAIUser
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "enrichmentApp_OpenAiRole" {
  Provider                      = azurrm.HUBSub      
  source = "./core/security/role"

  scope            = var.useExistingAOAIService ? data.azurerm_resource_group.existing[0].id : data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.enrichmentApp.identityPrincipalId
  roleDefinitionId = local.azure_roles.CognitiveServicesOpenAIUser
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "webApp_CognitiveServicesUser" {
  Provider                      = azurrm.HUBSub      
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.webapp.identityPrincipalId
  roleDefinitionId = local.azure_roles.CognitiveServicesUser
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "functionApp_CognitiveServicesUser" {
  Provider                      = azurrm.HUBSub      
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.functions.identityPrincipalId
  roleDefinitionId = local.azure_roles.CognitiveServicesUser
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "enrichmentApp_CognitiveServicesUser" {
  Provider                      = azurrm.HUBSub    
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.enrichmentApp.identityPrincipalId
  roleDefinitionId = local.azure_roles.CognitiveServicesUser
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "enrichmentApp_StorageQueueDataContributor" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.enrichmentApp.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageQueueDataContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "functionApp_StorageQueueDataContributor" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.functions.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageQueueDataContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "webApp_StorageBlobDataContributor" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.webapp.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageBlobDataContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "webApp_SearchIndexDataReader" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.webapp.identityPrincipalId
  roleDefinitionId = local.azure_roles.SearchIndexDataReader
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "functionApp_SearchIndexDataContributor" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.functions.identityPrincipalId
  roleDefinitionId = local.azure_roles.SearchIndexDataContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "encrichmentApp_SearchIndexDataContributor" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.enrichmentApp.identityPrincipalId
  roleDefinitionId = local.azure_roles.SearchIndexDataContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "fuctionApp_StorageBlobDataOwner" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.functions.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageBlobDataOwner
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "enrichmentApp_StorageBlobDataOwner" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.enrichmentApp.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageBlobDataOwner
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

module "fuctionApp_StorageAccountContributor" {
  Provider = data.azurerm.SHAREDSERVICES
  source = "./core/security/role"
  scope            = data.azurerm_resource_group.InfoAssistRG.id
  principalId      = module.functions.identityPrincipalId
  roleDefinitionId = local.azure_roles.StorageAccountContributor
  principalType    = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "webApp_cosmosdb_data_contributor" {
  provider = azurerm.SHAREDSERVICESSub
  resource_group_name = var.InfoAssistResourceGroupName
  account_name = module.cosmosdb.name
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${module.cosmosdb.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002" #Cosmos DB Built-in Data Contributor
  principal_id = module.webapp.identityPrincipalId
  scope = module.cosmosdb.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "functionApp_cosmosdb_data_contributor" {
  provider = azurerm.SHAREDSERVICESSub
  resource_group_name = var.InfoAssistResourceGroupName
  account_name = module.cosmosdb.name
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${module.cosmosdb.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002" #Cosmos DB Built-in Data Contributor
  principal_id = module.functions.identityPrincipalId
  scope = module.cosmosdb.id
}

resource "azurerm_cosmosdb_sql_role_assignment" "enrichmentApp_cosmosdb_data_contributor" {
  provider = azurerm.SHAREDSERVICESSub  
  resource_group_name = var.InfoAssistResourceGroupName
  account_name = module.cosmosdb.name
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.InfoAssistResourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${module.cosmosdb.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002" #Cosmos DB Built-in Data Contributor
  principal_id = module.enrichmentApp.identityPrincipalId
  scope = module.cosmosdb.id
}

module "docIntel_StorageBlobDataReader" {
  Provider = data.azurerm.SHAREDSERVICES  
  source = "./core/security/role"
  scope = data.azurerm_resource_group.InfoAssistRG.id
  principalId = module.aiDocIntelligence.docIntelligenceIdentity
  roleDefinitionId = local.azure_roles.StorageBlobDataReader
  principalType = "ServicePrincipal"
  subscriptionId = data.azurerm_client_config.current.subscription_id
  resourceGroupId = data.azurerm_resource_group.InfoAssistRG.id
}

# // MANAGEMENT SERVICE PRINCIPAL ROLES
module "openAiRoleMgmt" {
  Provider = data.azurerm.SHAREDSERVICES    
  source = "./core/security/role"
  # If leveraging an existing Azure OpenAI service, only make this assignment if not under automation.
  # When under automation and using an existing Azure OpenAI service, this will result in a duplicate assignment error.
  count = var.useExistingAOAIService ? var.isInAutomation ? 0 : 1 : 1
  scope = var.useExistingAOAIService ? data.azurerm_resource_group.existing[0].id : data.azurerm_resource_group.InfoAssistRG.id
  principalId     = module.entraObjects.azure_ad_mgmt_sp_id
  roleDefinitionId = local.azure_roles.CognitiveServicesOpenAIUser
  principalType   = "ServicePrincipal"
  subscriptionId   = data.azurerm_client_config.current.subscription_id
  resourceGroupId  = data.azurerm_resource_group.InfoAssistRG.id
}

// DEPLOYMENT OF AZURE CUSTOMER ATTRIBUTION TAG
resource "azurerm_resource_group_template_deployment" "customer_attribution" {
  provider            = azurerm.SHAREDSERVICESSub
  count               = var.cuaEnabled ? 1 : 0
  name                = "pid-${var.cuaId}"
  resource_group_name = var.InfoAssistResourceGroupName
  deployment_mode     = "Incremental"
  template_content    = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": []
}
TEMPLATE
}