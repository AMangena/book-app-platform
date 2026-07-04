# ─────────────────────────────────────────────────────────────
# modules/webapp/main.tf — the REUSABLE module.
# Defined ONCE. Called by dev, staging, AND prod with different values.
# Nothing is hardcoded — every value comes from a variable.
# ─────────────────────────────────────────────────────────────

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_service_plan" "plan" {
  name                = var.plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = var.sku_name      # ← dev/staging/prod can differ here
  tags                = var.tags
}

resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  tags                = var.tags

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }
}
