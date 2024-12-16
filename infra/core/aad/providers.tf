terraform {
  required_version = ">= 0.15.3"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.47.0"
    }
  }
}

provider "azuread" {
  environment = var.azure_environment == "AzureUSGovernment" ? "usgovernment" : "public"
}
