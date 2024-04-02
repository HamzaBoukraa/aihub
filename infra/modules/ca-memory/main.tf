resource "azapi_resource" "ca_back" {
  name                      = var.ca_name
  location                  = var.location
  parent_id                 = var.resource_group_id
  type                      = "Microsoft.App/containerApps@2023-11-02-preview"
  schema_validation_enabled = false
  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    properties : {
      managedEnvironmentId = "${var.cae_id}"
      configuration = {
        secrets = [
          {
            name  = "aoai-key"
            value = var.chat_gpt_key
          },
          {
            name  = "doc-intel-key"
            value = var.doc_intelligence_service_key
          }
        ]
        ingress = {
          external   = true
          targetPort = 9001
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
            name  = "kernel-memory"
            image = "docker.io/kernelmemory/service:latest"
            resources = {
              cpu    = 0.5
              memory = "1Gi"
            }
            env = [
              {
                name  = "ASPNETCORE_ENVIRONMENT"
                value = "Development"
              },
              {
                name  = "KernelMemory__Services__AzureOpenAIText__Endpoint"
                value = var.chat_gpt_endpoint
              },
              {
                name      = "KernelMemory__Services__AzureOpenAIText__APIKey"
                secretRef = "aoai-key"
              },
              {
                name  = "KernelMemory__Services__AzureOpenAIText__Deployment"
                value = var.chat_gpt_deployment
              },
              {
                name  = "KernelMemory__Services__AzureOpenAIEmbedding__Deployment"
                value = var.embeddings_deployment
              },
              {
                name      = "KernelMemory__Services__AzureOpenAIEmbedding__APIKey"
                secretRef = "aoai-key"
              },
              {
                name  = "KernelMemory__Services__AzureOpenAIEmbedding__Endpoint"
                value = var.chat_gpt_endpoint
              },
              {
                name  = "KernelMemory__TextGeneratorType"
                value = "AzureOpenAIText"
              },
              {
                name  = "KernelMemory__DataIngestion__TextIngestion__EmbeddingGeneratorTypes__0"
                value = "AzureOpenAIEmbedding"
              },
              {
                name  = "KernelMemory__DataIngestion__EmbeddingGeneratorTypes__0"
                value = "AzureOpenAIEmbedding"
              },
              {
                name  = "KernelMemory__Retrieval__EmbeddingGeneratorType"
                value = "AzureOpenAIEmbedding"
              },
              {
                name  = "KernelMemory__Service__OpenApiEnabled"
                value = "true"
              },
              {
                name  = "KernelMemory__Services__AzureOpenAIText__Auth"
                value = "ApiKey"
              },
              {
                name  = "KernelMemory__Services__AzureOpenAIEmbedding__Auth"
                value = "ApiKey"
              },
              {
                name  = "KernelMemory__Services__AzureOpenAIText__MaxTokenTotal"
                value = "4096"
              },
              {
                name  = "KernelMemory__Services__Qdrant__Endpoint"
                value = "http://ca-qdrantdb:6333"
              },
              {
                name  = "KernelMemory__DataIngestion__MemoryDbTypes__1"
                value = "Qdrant"
              },
              {
                name  = "KernelMemory__ContentStorageType"
                value = "AzureBlobs"
              },
              {
                name  = "KernelMemory__Services__AzureBlobs__Account"
                value = var.storage_account_name
              },
              {
                name  = "KernelMemory__DataIngestion__ImageOcrType"
                value = "AzureAIDocIntel"
              },
              {
                name  = "KernelMemory__Services__AzureAIDocIntel__Endpoint"
                value = var.doc_intelligence_service_endpoint
              },
              {
                name      = "KernelMemory__Services__AzureAIDocIntel__ApiKey"
                secretRef = "doc-intel-key"
              },
              {
                name  = "KernelMemory__Services__AzureAIDocIntel__Auth"
                value = "APIKey"
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

resource "azurerm_role_assignment" "storage_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azapi_resource.ca_back.identity[0].principal_id
}
