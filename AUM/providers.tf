provider "azurerm" {
  features {}
  
  
}
# Grabs client deployment context (Tenant ID, Client ID, etc.)
data "azurerm_client_config" "current" {}