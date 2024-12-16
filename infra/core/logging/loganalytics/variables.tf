variable "ResourceNamingConvention" {
  description = "Naming Prefix for Deployed Resources"
  type        = string
}

variable "location" {
  type    = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "skuName" {
  type    = string
  default = "PerGB2018"
}

variable "InfoAssistResourceGroupName" {
  type    = string
}

variable "APDZResourceGroupName" {
  type    = string
}

variable "logWorkbookName" {
  description = "The name of the log workbook"
  type        = string
  default     = ""
}

variable "componentResource" {
  description = "The component resource"
  type        = string
  default     = ""
}

variable "is_secure_mode" {
  type    = bool
  default = false
}

variable "vnet_id" {
  type = string
}

variable "privateDnsZoneNameMonitor" {
  type = string
}

variable "privateDnsZoneNameOms" {
  type = string
}

variable "privateDnSZoneNameOds" {
  type = string
}

variable "privateDnsZoneNameAutomation" {
  type = string
}

variable "privateDnsZoneResourceIdBlob" {
  type = string
}

variable "privateDnsZoneNameBlob" {
  type = string
}

variable "groupId" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "ampls_subnet_CIDR" {
  type = string
}

variable "nsg_name" {
  type = string
}

variable "nsg_id" {
  type = string
}