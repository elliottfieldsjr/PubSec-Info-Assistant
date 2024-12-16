terraform {
  required_version = ">= 0.15.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
  }
}

provider "azurerm" {
  alias       = "HUBSub"  
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id            = var.HubSubscriptionID
  resource_provider_registrations = "none"
  storage_use_azuread = true
  environment = var.azure_environment == "AzureUSGovernment" ? "usgovernment" : "public"
}

provider "azurerm" {
  alias       = "IDENTITYSub"  
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id            = var.IdentitySubscriptionID
  resource_provider_registrations = "none"
  storage_use_azuread = true
  environment = var.azure_environment == "AzureUSGovernment" ? "usgovernment" : "public"
}

provider "azurerm" {
  alias       = "OPERATIONSSub"  
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id            = var.OperationsSubscriptionID
  resource_provider_registrations = "none"
  storage_use_azuread = true
  environment = var.azure_environment == "AzureUSGovernment" ? "usgovernment" : "public"
}

provider "azurerm" {
  alias       = "SHAREDSERVICESSub"  
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id            = var.SharedServicesSubscriptionID
  resource_provider_registrations = "none"
  storage_use_azuread = true
  environment = var.azure_environment == "AzureUSGovernment" ? "usgovernment" : "public"
}

provider "azuread" {
  alias       = "Tenant1"    
  environment = var.azure_environment == "AzureUSGovernment" ? "usgovernment" : "public"
}
