terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "home/proxmox/tf"
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
    name = "vault-token"
    path = "vault-keys/token/vault-token"
  }
  key {
    name = "proxmox-url"
    path = "home/proxmox/url"
  }
}

provider "vault" {
  address         = "http://127.0.0.1:8200"
  skip_tls_verify = true
  token           = data.consul_keys.config.var.vault-token
}

provider "proxmox" {
  pm_api_url = data.consul_keys.config.var.proxmox-url
}