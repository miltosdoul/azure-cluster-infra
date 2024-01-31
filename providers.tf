terraform {
  required_version = ">=1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }

  backend "azurerm" {
    resource_group_name  = "storage-resource-group"
    storage_account_name = "azureplatformtfstate123"
    container_name       = "tfstate-github-actions"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}