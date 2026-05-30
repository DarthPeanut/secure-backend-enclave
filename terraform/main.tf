resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Environment = var.environment
    ManagedBy = "Terraform"
  }
}

resource "random_string" "suffix" {
    length = 6
    special = false
    upper = false
}

resource "azurerm_virtual_network" "vnet" {
  count = var.enable_strict_isolation ? 1 : 0
  name = "secure-enclave-vnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "compute_subnet" {
    count = var.enable_strict_isolation ? 1 : 0
    name = "aca-compute-subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet[0].name
    address_prefixes = ["10.0.1.0/23"]
    
    delegation {
        name = "containerapps-delegation"
        service_delegation { 
            name = "Microsoft.App/environments"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action", "Microsoft.Network/virtualNetworks/subnets/preparedNetworkPolicies/action"]

        }
    }
}

resource "azurerm_container_registry" "acr" {
    name = "enclaveacr${random_string.suffix.result}"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    #Have to use basic because I dont want to pay for it 
    sku = var.enable_strict_isolation ? "Premium" : "Basic"
    admin_enabled = true
}
#Free Tier
resource "azurerm_log_analytics_workspace" "law"{
    name = "platform-logs"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "PerGB2018"
    retain_in_days = 30
}

resource "azurerm_container_app_environment" "env" {
    name = "enclave-kube-fabric"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

    infrastructure_subnet_id = var.enable_strict_isolation ? azurerm_subnet.compute_subnet[0].id : null
    internal_load_balancer_enabled = var.enable_strict_isolation ? true : false
}

resource "azurerm_container_app" "app" {
    name = "secure-service"
    container_app_environment_id = azurerm_container_app_environment.env.id
    resource_group_name = azurerm_resource_group.rg.name
    revision_mode = "Single"

    registry{
        server = azurerm_container_registry.acr.login_server
        username = azurerm_container_registry.acr.admin_username
        password_secret_name = "acr-password"
    }
    secret {
        name = "acr-password"
        value = azurerm_container_registry.acr.admin_password
    }
    template {
        container {
            name = "api"
            image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
            cpu = "0.25"
            memory = "0.5Gi"
        }
    }
    
    ingress {
        allow_insecure_connections = false
        target_port = 80
        external_enabled = true
        traffic_weight {
            percentage = 100
            latest_revision = true
        }
    }
}

output "resource_group_name" {
    value = azurerm_resource_group.rg.name
    description = "Core dployment rg name"
}

output "container_registry_name" {
    value = azurerm_container_registry.acr.name
    description = "The name of the container registry"
}

output "container_registry_server" {
    value = azurerm_container_registry.acr.login_server
    description = "The login server of the container registry"
}

output "container_app_name" {
    value = azurerm_container_app.app.name
    description = "The name of the container app"
}
