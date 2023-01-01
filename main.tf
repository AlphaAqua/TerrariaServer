terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.12"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subid
  tenant_id       = var.tenantid
}

resource "azurerm_resource_group" "main" {
  name     = var.RESOURCE_GROUP_NAME
  location = var.REGION
}

resource "azurerm_storage_account" "main" {
  name                     = "terrariajpandnickaccount"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}



resource "azurerm_storage_share" "gamedata" {
  name                 = "terrariajpandnickshare"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 50
}


resource "azurerm_container_group" "gameserv" {
  name                = "terraria-gameserverjpandnick"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_address_type     = "public"
  dns_name_label      = var.dns_label
  os_type             = "Linux"

  container {
    name   = "terrariagame"
    image  = "trfc/terraria:${var.terraria_server_version}"
    cpu    = var.n_cores
    memory = var.mem_gb

    ports {
      port     = 7777
      protocol = "TCP"
    }

    volume {
      name                 = "gamedatamount"
      mount_path           = "/world"
      storage_account_name = azurerm_storage_account.main.name
      storage_account_key  = azurerm_storage_account.main.primary_access_key
      share_name           = azurerm_storage_share.gamedata.name
    }

    commands = [ "-autocreate", "1", "-world", "/world/Terrarium.wld", "-password", "JpAndNick1!play2!terraria" ]
  }
}
