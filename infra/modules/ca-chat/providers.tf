terraform {
  required_version = ">= 1.1.8"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.87.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}
