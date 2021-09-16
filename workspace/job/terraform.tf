terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "tf/console/job"
    gzip    = true
  }
}

provider "vault" {
  address = "https://10.10.30.121:8200"
}

data "vault_generic_secret" "consul_role" {
  path = "consul/creds/consul-server-role"
}

provider "consul" {
  alias   = "home"
  address = "10.10.30.99:8500"
  token   = data.vault_generic_secret.consul_role.data.token
}

// manually bootstrap acl and configure vault nomad engine
resource "vault_nomad_secret_role" "terraform" {
  backend = "nomad"
  role    = "terraform"
  type    = "management"
}

data "vault_nomad_access_token" "token" {
  backend    = "nomad"
  role       = vault_nomad_secret_role.terraform.role
  depends_on = [vault_nomad_secret_role.terraform]
}

provider "nomad" {
  address   = "http://10.10.30.210:4646"
  secret_id = data.vault_nomad_access_token.token.secret_id
}
