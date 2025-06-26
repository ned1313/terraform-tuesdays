resource "random_string" "container_name" {
  length  = 25
  lower   = true
  upper   = false
  special = false
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${local.default_suffix}"
  location = var.location
  
}

resource "azapi_resource" "log_analytics_workspace" {
  type      = "Microsoft.OperationalInsights/workspaces@2025-02-01"
  name      = "law-${var.container_group_name_prefix}-${random_string.container_name.result}"
  location  = var.location
  parent_id = azurerm_resource_group.example.id
  body = {
    properties = {
      sku = {
        name = "PerGB2018"
      }
      retentionInDays = 30
    }
  }
  tags = local.default_tags
}

ephemeral "azapi_resource_action" "law_shared_key" {
  action                 = "sharedKeys"
  method                 = "POST"
  resource_id            = azapi_resource.log_analytics_workspace.output.id
  type                   = "Microsoft.OperationalInsights/workspaces@2020-08-01"
  response_export_values = ["primarySharedKey", "secondarySharedKey"]
}

resource "azapi_resource" "container" {
  type      = "Microsoft.ContainerInstance/containerGroups@2023-05-01"
  name      = "${var.container_group_name_prefix}-${random_string.container_name.result}"
  location  = var.location
  parent_id = azurerm_resource_group.example.id
  body = {
    properties = {
      containers = [
        {
          name = "${var.container_name_prefix}-${random_string.container_name.result}"
          properties = {
            image = var.image
            resources = {
              requests = {
                cpu        = var.cpu_cores
                memoryInGB = var.memory_in_gb
              }
            }
            ports = [
              {
                port     = var.port
                protocol = "TCP"
              }
            ]
          }
        }
      ]
      diagnostics = {
        logAnalytics = {
          logType             = "ContainerInsights"
          workspaceId         = azapi_resource.log_analytics_workspace.output.properties.customerId
          workspaceResourceId = azapi_resource.log_analytics_workspace.output.id
        }
      }
      osType        = "Linux"
      restartPolicy = var.restart_policy
      ipAddress = {
        type = "Public"
        ports = [
          {
            port     = var.port
            protocol = "TCP"
          }
        ]
      }
    }
  }
  response_export_values = ["properties.ipAddress.ip"]
  sensitive_body = {
    properties = {
      diagnostics = {
        logAnalytics = {
          workspaceKey = ephemeral.azapi_resource_action.law_shared_key.output.secondarySharedKey
        }
      }
    }
  }
  schema_validation_enabled = false
  tags                      = local.default_tags
}