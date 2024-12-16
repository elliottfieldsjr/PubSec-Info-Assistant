terraform {
  required_version = ">= 0.15.3"
  required_providers {
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

provider "azuread" {
  alias       = "Tenant1"    
  environment = var.azure_environment == "AzureUSGovernment" ? "usgovernment" : "public"
}
