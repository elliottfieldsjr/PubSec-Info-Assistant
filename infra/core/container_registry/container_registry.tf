resource "azurerm_container_registry" "acr" {
  provider            = azurerm.SHAREDSERVICESSub              
  name                = lower(var.name)
  resource_group_name = var.resourceGroupName
  location            = var.location
  sku                 = "Premium"  // Premium is required for networking features
  admin_enabled       = true       // Enables the admin account for Docker login

  public_network_access_enabled = true

  network_rule_set = [{
    default_action = "Deny"
    ip_rule = [
      {
        action   = "Allow"
        ip_range = "${var.CloudShellIP}/32"
      },
    ],
  }]

}

data "azurerm_subnet" "subnet" {
  provider             = azurerm.SHAREDSERVICESSub              
  count                = var.is_secure_mode ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resourceGroupName
}

resource "azurerm_private_endpoint" "ContainerRegistryPrivateEndpoint" {
  provider                      = azurerm.SHAREDSERVICESSub              
  count                         = var.is_secure_mode ? 1 : 0
  name                          = "${var.name}-private-endpoint"
  location                      = var.location
  resource_group_name           = var.resourceGroupName
  subnet_id                     = data.azurerm_subnet.subnet[0].id
  tags                          = var.tags
  custom_network_interface_name = "infoasstacrnic"

  private_service_connection {
    name                            = "${var.name}-private-link-service-connection"
    private_connection_resource_id  = azurerm_container_registry.acr.id
    is_manual_connection            = false
    subresource_names               = ["registry"]
  }

  private_dns_zone_group {
    name                 = "${var.name}PrivateDnsZoneGroup"
    private_dns_zone_ids = var.private_dns_zone_ids
  }
}