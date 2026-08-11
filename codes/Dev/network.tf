locals {
  network_tags = merge(
    local.common_tags,
    {
      Tag_Env                = var.environment
      Tag_DataClassification = "Confidential"
      Tag_System             = "PSYNAPS"
      Tag_Criticality        = "High"
    }
  )

  vnet_name = "vnet-psynaps-prd"

  dev_subnets = {
    dev = {
      name       = "snet-psynaps-dev"
      prefix     = "10.14.167.0/26"
      delegation = null
    }
    aca = {
      name   = "snet-ca-psynaps-dev"
      prefix = "10.14.167.64/27"
      delegation = {
        name         = "delegation-container-apps"
        service_name = "Microsoft.App/environments"
      }
    }
  }

  bastion_subnet = {
    name   = "AzureBastionSubnet"
    prefix = "10.14.165.192/26"
  }
}

data "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  resource_group_name = "rg-psynaps-prd"
}

resource "azurerm_subnet" "dev" {
  for_each = local.dev_subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.this.name
  address_prefixes     = [each.value.prefix]

  dynamic "delegation" {
    for_each = each.value.delegation == null ? [] : [each.value.delegation]

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_name
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

resource "azurerm_subnet" "bastion" {
  name                 = local.bastion_subnet.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.this.name
  address_prefixes     = [local.bastion_subnet.prefix]
}

resource "azurerm_network_security_group" "dev" {
  name                = "nsg-psynaps-dev"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = local.network_tags
}

resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-azurebastion-psynaps"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowGatewayManagerInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowBastionHostCommunication"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSshRdpOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "AllowBastionCommunication"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowHttpOutbound"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  tags = local.network_tags
}

resource "azurerm_route_table" "dev" {
  name                          = "rt-psynaps-dev"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = true

  route {
    name           = "default-to-vng"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualNetworkGateway"
  }

  tags = local.network_tags
}

resource "azurerm_subnet_network_security_group_association" "dev" {
  for_each = {
    for key, subnet in azurerm_subnet.dev : key => subnet if contains(["dev", "aca"], key)
  }

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.dev.id
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_subnet_route_table_association" "dev" {
  for_each = {
    for key, subnet in azurerm_subnet.dev : key => subnet if contains(["dev", "aca"], key)
  }

  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.dev.id
}