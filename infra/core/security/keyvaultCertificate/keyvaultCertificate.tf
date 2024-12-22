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

resource "azurerm_key_vault_certificate" "Certificate1" {
  name         = var.CertificateFileName
  key_vault_id = var.KeyVaultID

  certificate {
    contents = filebase64("${var.CertificateFileName}.pfx")
    password = var.CertificatePassword
  }

  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}