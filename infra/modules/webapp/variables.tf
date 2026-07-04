# modules/webapp/variables.tf — the inputs the module accepts from each environment.

variable "resource_group_name" {
  type = string
}

variable "plan_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "B1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
