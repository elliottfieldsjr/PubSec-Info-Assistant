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