
resource "azurerm_fabric_capacity" "this" {
  name                = "fabriccapacitydev"
  resource_group_name = var.resource_group_name
  location            = var.location

  administration_members = [
    "azfw-test@youthk800gmail.onmicrosoft.com",
    "youth.k800_gmail.com#EXT#@youthk800gmail.onmicrosoft.com",
  ]

  sku {
    name = "F8"
    tier = "Fabric"
  }

  tags = merge(
    local.common_tags,
    {
      Tag_Env                = var.environment
      Tag_DataClassification = "Confidential"
      Tag_System             = "PSYNAPS"
      Tag_Criticality        = "High"
    }
  )
}
