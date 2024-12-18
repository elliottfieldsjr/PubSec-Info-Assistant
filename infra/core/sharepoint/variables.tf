
variable "WorkFlowName" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_access_key" {
  type = string
  sensitive = true
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {}

variable "subscription_id" {
  type = string
}


