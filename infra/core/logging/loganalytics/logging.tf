
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
  count               = var.is_secure_mode ? 1 : 0  
  name                = var.LAWName
  resource_group_name = var.LAWResourceGroupName
}

data "azurerm_monitor_private_link_scope" "ExistingAMPLS" {
  count               = var.is_secure_mode ? 1 : 0
  name                = var.AMPLSName
  resource_group_name = var.LAWResourceGroupName
}

resource "azurerm_application_insights" "applicationInsights" {
  provider = azurerm.OPERATIONS
  name                = "${var.ResourceNamingConvention}-ai"
  location            = var.location
  resource_group_name = var.LAWResourceGroupName
  application_type    = "web"
  tags                = var.tags
  workspace_id        = data.azurerm_log_analytics_workspace.ExistingLAW.id
}

// Create Diagnostic Setting for NSG here since the log analytics workspace is created here after the network is created
resource "azurerm_monitor_diagnostic_setting" "nsg_diagnostic_logs" {
  provider                   = azurerm.OPERATIONS
  count                      = var.is_secure_mode ? 1 : 0
  name                       = var.nsg_name
  target_resource_id         = var.nsg_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.ExistingLAW.id
  enabled_log  {
    category = "NetworkSecurityGroupEvent"
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
}

// add scope resoruce for app insights
resource "azurerm_monitor_private_link_scoped_service" "ampl_ss_app_insights" {
  provider            = azurerm.OPERATIONS  
  count               = var.is_secure_mode ? 1 : 0
  name                = "${var.ResourceNamingConvention}-ampls-appInsights-connection"
  resource_group_name = var.LAWResourceGroupName
  scope_name          = var.AMPLSName
  linked_resource_id  = azurerm_application_insights.applicationInsights.id
}


resource "azurerm_private_dns_a_record" "monitor_api" {
  provider = azurerm.HUBSub  
  count               = var.is_secure_mode ? 1 : 0
  name                = "api"
  zone_name           = var.privateDnsZoneNameMonitor
  resource_group_name = var.APDZResourceGroupName
  ttl                 = 3600
  records             = [cidrhost(var.ampls_subnet_CIDR, 7)]
}

resource "azurerm_private_dns_a_record" "monitor_global" {
  provider = azurerm.HUBSub    
  count               = var.is_secure_mode ? 1 : 0
  name                = "global.in.ai"
  zone_name           = var.privateDnsZoneNameMonitor
  resource_group_name = var.APDZResourceGroupName
  ttl                 = 3600
  records             = [cidrhost(var.ampls_subnet_CIDR, 8)]
}

resource "azurerm_private_dns_a_record" "monitor_profiler" {
  provider = azurerm.HUBSub    
  count               = var.is_secure_mode ? 1 : 0
  name                = "profiler"
  zone_name           = var.privateDnsZoneNameMonitor
  resource_group_name = var.APDZResourceGroupName
  ttl                 = 3600
  records             = [cidrhost(var.ampls_subnet_CIDR, 9)]
}

resource "azurerm_private_dns_a_record" "monitor_live" {
  provider = azurerm.HUBSub    
  count               = var.is_secure_mode ? 1 : 0
  name                = "live"
  zone_name           = var.privateDnsZoneNameMonitor
  resource_group_name = var.APDZResourceGroupName
  ttl                 = 3600
  records             = [cidrhost(var.ampls_subnet_CIDR, 10)]
}

resource "azurerm_private_dns_a_record" "monitor_snapshot" {
  provider = azurerm.HUBSub    
  count               = var.is_secure_mode ? 1 : 0
  name                = "snapshot"
  zone_name           = var.privateDnsZoneNameMonitor
  resource_group_name = var.APDZResourceGroupName
  ttl                 = 3600
  records             = [cidrhost(var.ampls_subnet_CIDR, 11)]
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