terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "tf/console/job"
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
  address         = "http://10.10.30.121:8200"
  skip_tls_verify = true
  token           = data.consul_keys.config.var.vault_token
}

// manually bootstrap acl and configure vault nomad engine
resource "vault_nomad_secret_role" "terraform" {
  backend   = "nomad"
  role      = "terraform"
  type      = "management"
}

data "vault_nomad_access_token" "token" {
  backend = "nomad"
  role    = vault_nomad_secret_role.terraform.role
  depends_on = [vault_nomad_secret_role.terraform]
}

provider "nomad" {
  address = "http://10.10.30.210:4646"
  secret_id  = data.vault_nomad_access_token.token.secret_id
}
