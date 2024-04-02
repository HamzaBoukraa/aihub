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
            name  = "aoai-key"
            value = "<aoai-key>"
          }
        ]
        ingress = {
          external   = true
          targetPort = 8080
          transport  = "Http"

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
      }
      template = {
        containers = [
          {

            name  = "weather"
            image = "ghcr.io/dsanchor/weather-forecast-oai-plugin:c92efd54793108a9c5e79b29fe74beaf502d0562"
            resources = {
              cpu    = 0.5
              memory = "1Gi"
            }
            env = [
              {
                name      = "CLIENT_AZUREOPENAI_KEY"
                secretRef = "aoai-key"
              },
              {
                name  = "CLIENT_AZUREOPENAI_ENDPOINT"
                value = "https://azureopenaidsr.openai.azure.com"
              },
              {
                name  = "CLIENT_AZUREOPENAI_DEPLOYMENTNAME"
                value = "gpt-35-turbo"
              },
              {
                name  = "OAI_PLUGIN_BASEURL"
                value = "https://${var.ca_name}.${var.cae_default_domain}"
              }
            ],
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
