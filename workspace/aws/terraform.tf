terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "home/aws/tf"
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
    path = "home/proxmox/variables/proxmox-url"
  }
}

provider "vault" {
  address         = "http://127.0.0.1:8200"
  skip_tls_verify = true
  token           = data.consul_keys.config.var.vault_token
}