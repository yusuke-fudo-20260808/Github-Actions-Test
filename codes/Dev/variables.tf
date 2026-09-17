variable "subscription_id" {
  description = "サブスクリプションID"
  type        = string
}

variable "location" {
  description = "Azureリージョン"
  type        = string
}

#variable "vnet_name" {
#  description = "仮想ネットワーク名"
#  type        = string
#}

variable "environment" {
  description = "環境識別子（dev/test/prod）"
  type        = string
}
