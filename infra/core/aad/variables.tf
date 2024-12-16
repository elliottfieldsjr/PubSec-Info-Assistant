//// Variables that can vary based on the Azure environment being targeted
variable "azure_environment" {
  type        = string
  default     = "AzureCloud"
  description = "The Azure Environemnt to target. More info can be found at https://docs.microsoft.com/en-us/cli/azure/manage-clouds-azure-cli?toc=/cli/azure/toc.json&bc=/cli/azure/breadcrumb/toc.json. Defaults to value for 'AzureCloud'"
}

variable "HubSubscriptionID" {
  description = "HUB Subscription ID"
  type        = string
}

variable "IdentitySubscriptionID" {
  description = "IDENTITY Subscription ID"
  type        = string
}

variable "OperationsSubscriptionID" {
  description = "OPERATIONS Subscription ID"
  type        = string
}

variable "SharedServicesSubscriptionID" {
  description = "SHARED SERVICES Subscription ID"
  type        = string
}

variable "randomString" {
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