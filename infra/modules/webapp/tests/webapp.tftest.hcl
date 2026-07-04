# Terraform native tests for the webapp module.
# Run locally with:  terraform test   (from infra/modules/webapp)

mock_provider "azurerm" {}

# Default inputs used by every run below (a run can override them).
variables {
  resource_group_name = "test-rg"
  plan_name           = "test-plan"
  app_name            = "test-app-12345"
  location            = "southafricanorth"
}

# Test 1: the SKU defaults to B1 when not provided.
run "defaults_to_b1_sku" {
  command = plan

  assert {
    condition     = azurerm_service_plan.plan.sku_name == "B1"
    error_message = "Default SKU should be B1"
  }
}

# Test 2: the resource group is named from the input.
run "resource_group_uses_input_name" {
  command = plan

  assert {
    condition     = azurerm_resource_group.rg.name == "test-rg"
    error_message = "Resource group name should equal the provided input"
  }
}

# Test 3: prod can override the SKU to B2 (proves the env-difference works).
run "sku_is_overridable" {
  command = plan

  variables {
    sku_name = "B2"
  }

  assert {
    condition     = azurerm_service_plan.plan.sku_name == "B2"
    error_message = "SKU should be overridable (e.g. B2 for prod)"
  }
}
