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

locals {
  arm_file_path = "arm_templates/bing_search/bing.template.json"
}

resource "azurerm_resource_group_template_deployment" "bing_search" {
  resource_group_name = var.InfoAssistResourceGroupName
  parameters_content = jsonencode({
    "name"                      = { value = "${var.name}" },
    "location"                  = { value = "Global" },
    "sku"                       = { value = "${var.sku}" },
    "tags"                      = { value = var.tags },
  })
  
  template_content = templatefile(local.arm_file_path, {
    arm_template_schema_mgmt_api = var.arm_template_schema_mgmt_api
  })
  # The filemd5 forces this to run when the file is changed
  # this ensures the keys are up-to-date
  name            = "bingsearch-${filemd5(local.arm_file_path)}"
  deployment_mode = "Incremental"
}

module "bing_search_key" {  
  providers = {
    azurerm = azurerm
    azurerm.HUBSub = azurerm.HUBSub
    azurerm.OPERATIONSSub = azurerm.OPERATIONSSub
  }
  source                        = "../../security/keyvaultSecret"
  resourceGroupName             = var.KVResourceGroupName
  key_vault_name                = var.key_vault_name
  secret_name                   = "BINGSEARCH-KEY"
  secret_value                  = jsondecode(azurerm_resource_group_template_deployment.bing_search.output_content).key1.value
  arm_template_schema_mgmt_api  = var.arm_template_schema_mgmt_api
  alias                         = "bingkey"
  tags                          = var.tags
  kv_secret_expiration          = var.kv_secret_expiration
  contentType                   = "application/vnd.bag-StrongEncPasswordString"
}