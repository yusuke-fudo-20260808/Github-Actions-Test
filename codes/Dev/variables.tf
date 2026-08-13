variable "subscription_id" {
  description = "サブスクリプションID"
  type        = string
}

variable "resource_group_name" {
  description = "リソースグループ名"
  type        = string
}

variable "location" {
  description = "Azureリージョン"
  type        = string
}

variable "vnet_name" {
  description = "仮想ネットワーク名"
  type        = string
}

variable "environment" {
  description = "環境識別子（dev/test/prod）"
  type        = string
}

variable "container_registry_name" {
  description = "既存のAzure Container Registry名"
  type        = string
}

variable "container_registry_resource_group_name" {
  description = "既存のAzure Container Registryが存在するリソースグループ名"
  type        = string
}
