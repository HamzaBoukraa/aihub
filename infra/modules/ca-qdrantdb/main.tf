resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azapi_resource" "ca_back" {
  name      = var.ca_name
  location  = var.location
  parent_id = var.resource_group_id
  type      = "Microsoft.App/containerApps@2023-05-01"
  identity {
    type = "None"
  }

  body = jsonencode({
    properties : {
      managedEnvironmentId = "${var.cae_id}"
      configuration = {
        secrets = [
          {
            name  = "qdrant-password"
            value = random_password.password.result
          }
        ]
        ingress = {
          external   = true
          targetPort = 6333
          transport  = "Tcp"

          traffic = [
            {
              latestRevision = true
              weight         = 100
            }
          ]
        }
        dapr = {
          enabled = false
        }
        service = {
          type = "qdrant"
        }
      }
      template = {
        containers = [
          {
            name  = "qdrant"
            image = "mcr.microsoft.com/k8se/services/qdrant:v1.4"
            resources = {
              cpu              = 1
              memory           = "2Gi"
            }
            env          = [],
            volumeMounts = []
          },
        ]
        scale = {
          minReplicas = 1
          maxReplicas = 1
        },
        volumes = []
      }
    }
  })
  response_export_values = ["properties.configuration.ingress.fqdn"]
}
