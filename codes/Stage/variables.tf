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

variable "network_resource_group_name" {
  description = "参照先VNet/Subnetが存在するリソースグループ名"
  type        = string
}

variable "resource_group_name_prd" {
  description = "リソースグループ名"
  type        = string
}

variable "stg_subnet_name" {
  description = "Stage向けプライベートエンドポイントを配置するサブネット名"
  type        = string
}

variable "acr_private_dns_zone_name" {
  description = "既存ACRプライベートDNSゾーン名"
  type        = string
}

variable "acr_private_dns_zone_resource_group_name" {
  description = "既存ACRプライベートDNSゾーンのリソースグループ名"
  type        = string
}

variable "key_vault_private_dns_zone_name" {
  description = "既存Key VaultプライベートDNSゾーン名"
  type        = string
}

variable "key_vault_private_dns_zone_resource_group_name" {
  description = "既存Key VaultプライベートDNSゾーンのリソースグループ名"
  type        = string
}

variable "cloud_connector_proxy_url" {
  description = "cloud connector が利用するプロキシURL"
  type        = string
}

variable "cloud_connector_gateway_url" {
  description = "cloud connector の接続先ゲートウェイURL"
  type        = string
}

variable "cloud_connector_fabric_sql_target" {
  description = "cloud connector の Fabric SQL 接続先引数"
  type        = string
}

variable "cloud_connector_fabric_dw_target" {
  description = "cloud connector の Fabric Data Warehouse 接続先引数"
  type        = string
}

variable "environment" {
  description = "環境識別子（dev/test/prod）"
  type        = string
}
