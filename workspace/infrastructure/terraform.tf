terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "tf/home"
    gzip    = true
  }

  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

provider "consul" {}

data "consul_keys" "config" {
  key {
    name = "vault_token"
    path = "vault-keys/token/vault-token"
  }
  key {
    name = "proxmox_url"
    path = "proxmox/url"
  }
}

provider "vault" {
  address         = "http://127.0.0.1:8200"
  skip_tls_verify = true
  token           = data.consul_keys.config.var.vault_token
}

data "vault_generic_secret" "proxmox_credentials" {
  path = "secret/home/proxmox"
}

provider "proxmox" {
  pm_api_url      = data.consul_keys.config.var.proxmox_url
  pm_user         = data.vault_generic_secret.proxmox_credentials.data.username
  pm_password     = data.vault_generic_secret.proxmox_credentials.data.password
  pm_tls_insecure = true
}