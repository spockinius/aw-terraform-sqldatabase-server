# Define Terraform provider
terraform {
  required_version = ">= 0.12"
}
#Configure the Azure Provider
provider "azurerm" {
  features {}
  version = ">= 2.0"
  environment = "public"
  subscription_id = var.azure_subscription_id
  tenant_id = var.azure_subscription_tenant_id
}
# RG create
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}
# SQL server create
resource "azurerm_sql_server" "example" {
  name                         = "servername"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = "West US"
  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  tags = {
    environment = "production"
  }
}
# storage account create
resource "azurerm_storage_account" "example" {
  name                     = "katakataexamplesa"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
# sql databse create
resource "azurerm_sql_database" "example" {
  name                = "myexamplesqldatabase"
  resource_group_name = azurerm_resource_group.example.name
  location            = "West US"
  server_name         = azurerm_sql_server.example.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.example.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.example.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }



  tags = {
    environment = "production"
  }
}
