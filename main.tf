resource "azurerm_resource_group" "platform-rg" {
  name     = "platform-rg-1"
  location = "West Europe"

  tags = {
    environment = "test"
  }
}

# resource "azurerm_virtual_network" "vnet" {
#   name                = "myVNet"
#   resource_group_name = azurerm_resource_group.platform-rg.name
#   location            = azurerm_resource_group.platform-rg.location
#   address_space       = ["10.21.0.0/16"]
# }

# resource "azurerm_subnet" "frontend" {
#   name                 = "myAGSubnet"
#   resource_group_name  = azurerm_resource_group.platform-rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.21.0.0/24"]
# }

# resource "azurerm_subnet" "backend" {
#   name                 = "myBackendSubnet"
#   resource_group_name  = azurerm_resource_group.platform-rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.21.1.0/24"]
# }

# resource "azurerm_public_ip" "pip" {
#   name                = "myAGPublicIPAddress"
#   resource_group_name = azurerm_resource_group.platform-rg.name
#   location            = azurerm_resource_group.platform-rg.location
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_application_gateway" "main" {
#   name                = "myAppGateway"
#   resource_group_name = azurerm_resource_group.platform-rg.name
#   location            = azurerm_resource_group.platform-rg.location

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 2
#   }

#   gateway_ip_configuration {
#     name      = "my-gateway-ip-configuration"
#     subnet_id = azurerm_subnet.frontend.id
#   }

#   frontend_port {
#     name = var.frontend_port_name
#     port = 80
#   }

#   frontend_ip_configuration {
#     name                 = var.frontend_ip_configuration_name
#     public_ip_address_id = azurerm_public_ip.pip.id
#   }

#   backend_address_pool {
#     name = var.backend_address_pool_name
#   }

#   backend_http_settings {
#     name                  = var.http_setting_name
#     cookie_based_affinity = "Disabled"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 60
#   }

#   http_listener {
#     name                           = var.listener_name
#     frontend_ip_configuration_name = var.frontend_ip_configuration_name
#     frontend_port_name             = var.frontend_port_name
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = var.request_routing_rule_name
#     rule_type                  = "Basic"
#     http_listener_name         = var.listener_name
#     backend_address_pool_name  = var.backend_address_pool_name
#     backend_http_settings_name = var.http_setting_name
#     priority                   = 1
#   }
# }

# resource "azurerm_network_interface" "nic" {
#   count               = 2
#   name                = "nic-${count.index + 1}"
#   location            = azurerm_resource_group.platform-rg.location
#   resource_group_name = azurerm_resource_group.platform-rg.name

#   ip_configuration {
#     name                          = "nic-ipconfig-${count.index + 1}"
#     subnet_id                     = azurerm_subnet.backend.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
#   count                   = 2
#   network_interface_id    = azurerm_network_interface.nic[count.index].id
#   ip_configuration_name   = "nic-ipconfig-${count.index + 1}"
#   backend_address_pool_id = one(azurerm_application_gateway.main.backend_address_pool).id
# }

resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "cluster"
}

resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
  prefix = "dns"
}

resource "azurerm_kubernetes_cluster" "k8s-cluster" {
  location            = azurerm_resource_group.platform-rg.location
  name                = random_pet.azurerm_kubernetes_cluster_name.id
  resource_group_name = azurerm_resource_group.platform-rg.name
  dns_prefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id

  # Identity type used for cluster to access other Azure resources.
  # With systemassigned, Azure creates and manages the identity and secrets
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name = "agentpool"
    # 1vCore, 2GiB RAM, 10GiB storage
    vm_size    = "Standard_A1_v2"
    node_count = var.node_count
  }
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  http_application_routing_enabled = true
}