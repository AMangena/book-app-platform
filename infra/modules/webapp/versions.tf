# modules/webapp/versions.tf — provider requirements for this module.
# Lets the module be validated/tested standalone (best practice: each module
# pins its providers).
terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
