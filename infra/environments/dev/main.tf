# environments/dev/main.tf — calls the SHARED module with THIS env's values.
terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Same module as the other environments — only the inputs differ.
module "webapp" {
  source              = "../../modules/webapp"
  resource_group_name = var.resource_group_name
  plan_name           = var.plan_name
  app_name            = var.app_name
  location            = var.location
  sku_name            = var.sku_name
  tags                = var.tags
}

output "app_url" {
  value = module.webapp.app_url
}
