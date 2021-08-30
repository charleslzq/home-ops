// bootstrap consul acl and setup token for all servers and clients. Unseal vault.
// consul server policy:
//   node_prefix "rayleigh" {
//     policy = "write"
//   }
//   node_prefix "" {
//     policy = "read"
//   }
//   service_prefix "" {
//     policy = "read"
//   }
//
// vault server policy:
//   node_prefix "" {
//     policy = "read"
//   }
//   service_prefix "" {
//     policy = "read"
//   }
//   node_prefix "yuki" {
//     policy = "write"
//   }
//   agent_prefix "yuki" {
//     policy = "write"
//   }
//
// vault service policy:
//   service "yuki" {
//      policy = "write"
//   }
//   key_prefix "vault/" {
//     policy = "write"
//   }
//   session_prefix "yuki" {
//     policy = "write"
//   }
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
