terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "tf/console/integration"
    gzip    = true
  }
}

provider "consul" {}

provider "consul" {
  alias   = "home"
  address = "http://10.10.30.100:8500"
}

data "consul_keys" "config" {
  key {
    name = "vault_token"
    path = "vault-keys/console/vault-token"
  }
}

provider "vault" {
  address         = "http://10.10.30.120:8200"
  skip_tls_verify = true
  token           = data.consul_keys.config.var.vault_token
}
