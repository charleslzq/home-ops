terraform {
  backend "consul" {
    address = "127.0.0.1:8500"
    scheme  = "http"
    path    = "tf/vault"
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

resource "vault_mount" "vm-client-signer" {
  type = "ssh"
  path = "vm-client-signer"
}

resource "vault_ssh_secret_backend_ca" "ca" {
  backend              = vault_mount.vm-client-signer.path
  generate_signing_key = true
}

resource "vault_ssh_secret_backend_role" "mac" {
  name                    = "mac"
  backend                 = vault_mount.vm-client-signer.path
  key_type                = "ca"
  allow_user_certificates = true
  allowed_users           = "*"
  allowed_extensions      = "permit-pty,permit-port-forwarding"
  default_extensions = {
    permit-pty = ""
  }
  default_user = "root"
  ttl          = "1800"
}
