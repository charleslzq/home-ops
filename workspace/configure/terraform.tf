terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "tf/configure"
    gzip    = true
  }
}

provider "vault" {
  address = "https://10.10.30.120:8200"
}

data "vault_generic_secret" "consul_role" {
  path = "consul/creds/consul-server-role"
}

provider "consul" {
  address = "10.10.30.99:8500"
  token   = data.vault_generic_secret.consul_role.data.token
}
