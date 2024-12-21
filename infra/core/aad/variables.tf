variable "WebAppName" {
  description = "Web App Name"
  type        = string
}

variable "AADWebName" {
  description = "Entra ID Web App Name"
  type        = string
}

variable "AADWebUri" {
  description = "Entra ID Web App Uri"
  type        = string
}

variable "AADMgmtName" {
  description = "Entra ID Management App Name"
  type        = string
}

variable "ObjectID" {
  type = string
}

variable "requireWebsiteSecurityMembership" {
  type = bool
  default = false
}

variable "azure_websites_domain" {
  type        = string
}

variable "isInAutomation" {
  type    = bool
  default = false
}

variable "aadWebClientId" {
  type = string
}

variable "aadMgmtClientId" {
  type = string
}

variable "aadMgmtServicePrincipalId" {
  type = string
}

variable "aadMgmtClientSecret" {
  type      = string
  sensitive = true
}

variable "entraOwners" {
  type    = string
  default = ""
  description = "Comma-separated list of owner emails"
}

variable "serviceManagementReference" {
  type      = string
  sensitive = true
}

variable "password_lifetime" {
  type      = number
}