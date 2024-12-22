variable "KeyVaultID" {
  type = string
}

variable "CertificateFileName" {
  type = string
}

variable "CertificatePassword" {
  type        = string
  sensitive   = true
}