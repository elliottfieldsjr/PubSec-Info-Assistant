output "certificate_thumbprint" {
  value = azurerm_key_vault_certificate.WebCertificate.thumbprint
}