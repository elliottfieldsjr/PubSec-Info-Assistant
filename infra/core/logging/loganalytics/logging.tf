terraform {
  required_version = ">= 0.15.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.3.0"
      configuration_aliases = [
        azurerm.HUBSub,
        azurerm.OPERATIONSSub,
       ]
    }
  }
}

data "azurerm_log_analytics_workspace" "ExistingLAW" {
  provider            = azurerm.OPERATIONSSub
  name                = var.LAWName
  resource_group_name = var.LAWResourceGroupName
}

resource "azurerm_application_insights" "applicationInsights" {
  provider = azurerm.OPERATIONSSub
  name                = var.AppInsightsName
  location            = var.location
  resource_group_name = var.LAWResourceGroupName
  application_type    = "web"
  tags                = var.tags
  workspace_id        = data.azurerm_log_analytics_workspace.ExistingLAW.id
}

// Create Diagnostic Setting for NSG here since the log analytics workspace is created here after the network is created
# resource "azurerm_monitor_diagnostic_setting" "nsg_diagnostic_logs" {
#   provider                   = azurerm.OPERATIONSSub
#   count                      = var.is_secure_mode ? 1 : 0
#   name                       = var.nsg_name
#   target_resource_id         = var.nsg_id
#   log_analytics_workspace_id = data.azurerm_log_analytics_workspace.ExistingLAW.id
#   enabled_log  {
#     category = "NetworkSecurityGroupEvent"
#   }
#   enabled_log {
#     category = "NetworkSecurityGroupRuleCounter"
#   }
# }

// add scope resoruce for app insights
resource "azurerm_monitor_private_link_scoped_service" "ampl_ss_app_insights" {
  provider            = azurerm.OPERATIONSSub
  count               = var.is_secure_mode ? 1 : 0
  name                = var.AppInsightsAMPLSName
  resource_group_name = var.LAWResourceGroupName
  scope_name          = var.AMPLSName
  linked_resource_id  = azurerm_application_insights.applicationInsights.id
}

resource "azurerm_private_dns_a_record" "oms_law_id" {
  provider = azurerm.HUBSub    
  count               = var.is_secure_mode ? 1 : 0
  name                = "infoasst-pl-oms-law-id"
  zone_name           = var.privateDnsZoneNameOms
  resource_group_name = var.APDZResourceGroupName
  ttl                 = 3600
  records             = [cidrhost(var.ampls_subnet_CIDR, 4)]
}

resource "azurerm_private_dns_a_record" "ods_law_id" {
  provider = azurerm.HUBSub    
  count               = var.is_secure_mode ? 1 : 0
  name                = "infoasst_pl_ods_law_id"
  zone_name           = var.privateDnSZoneNameOds
  resource_group_name = var.APDZResourceGroupName
  ttl                 = 3600
  records             = [cidrhost(var.ampls_subnet_CIDR, 5)]
}


resource "azurerm_private_dns_a_record" "agentsvc_law_id" {
  provider = azurerm.HUBSub    
  count               = var.is_secure_mode ? 1 : 0
  name                = "infoasst_pl_agentsvc_law_id"
  zone_name           = var.privateDnsZoneNameAutomation
  resource_group_name = var.APDZResourceGroupName
  ttl                 = 3600
  records             = [cidrhost(var.ampls_subnet_CIDR, 6)]
}

resource "azurerm_private_dns_a_record" "blob_scadvisorcontentpld" {
  provider = azurerm.HUBSub  
  count               = var.is_secure_mode ? 1 : 0
  name                = "scadvisorcontentpl"
  zone_name           = var.privateDnsZoneNameBlob
  resource_group_name = var.APDZResourceGroupName
  ttl                 = 3600
  records             = [cidrhost(var.ampls_subnet_CIDR, 12)]
}