terraform {
  required_version = ">= 0.15.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.3.0"
      configuration_aliases = [
        azurerm.HUBSub
       ]
    }
  }
}

resource "azurerm_key_vault_certificate" "WebCertificate" {
  name         = var.CertificateName
  key_vault_id = var.KeyVaultID

  certificate {
    contents = filebase64("${var.CertificateFilePath}")
    password = var.CertificatePassword
  }
}