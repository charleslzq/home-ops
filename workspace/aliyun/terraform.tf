terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "tf/aliyun/"
  }
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
    }
  }
}

provider "consul" {}

data "consul_keys" "config" {
  key {
    name = "vault_token"
    path = "vault-keys/token/vault-token"
  }
}

provider "vault" {
  address         = "http://127.0.0.1:8200"
  skip_tls_verify = true
  token           = data.consul_keys.config.var.vault_token
}