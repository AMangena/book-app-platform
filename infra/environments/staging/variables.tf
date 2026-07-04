variable "subscription_id" {
  type = string
}
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
  type    = string
  default = "southafricanorth"
}
variable "sku_name" {
  type    = string
  default = "B1"
}
variable "tags" {
  type    = map(string)
  default = {}
}
