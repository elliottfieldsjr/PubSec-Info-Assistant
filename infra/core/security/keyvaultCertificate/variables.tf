variable "KeyVaultID" {
  type = string
}

variable "CertificateName" {
  type = string
}

variable "CertificateFileName" {
  type = string
}

variable "CertificateFilePath" {
  type = string
}

variable "CertificatePassword" {
  type        = string
  sensitive   = true
}