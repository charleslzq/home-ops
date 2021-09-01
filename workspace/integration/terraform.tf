terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "tf/console/integration"
    gzip    = true
  }
}

provider "consul" {}

data "consul_keys" "config" {
  key {
    name = "vault_token"
    path = "vault-keys/console/vault-token"
  }
}

provider "vault" {
  address = "https://10.10.30.120:8200"
  token   = data.consul_keys.config.var.vault_token
}

data "vault_generic_secret" "consul_role" {
  path = "consul/creds/consul-server-role"
}

provider "consul" {
  alias   = "home"
  address = "10.10.30.99:8500"
  token   = data.vault_generic_secret.consul_role.data.token
}
