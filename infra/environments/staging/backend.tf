# environments/staging/backend.tf — this environment's REMOTE STATE.
# Note the unique 'key' — each environment gets its OWN state file in the
# same storage account, so dev/staging/prod states never mix.
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateamangena5094"
    container_name       = "tfstate"
    key                  = "staging.tfstate"
    use_azuread_auth     = true
  }
}
