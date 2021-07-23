provider "vault" {
  address         = "http://127.0.0.1:8200"
  skip_tls_verify = true
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
}
