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
  algorithm_signer        = "rsa-sha2-512"
  allow_user_certificates = true
  allowed_users           = "*"
  allowed_extensions      = "permit-pty,permit-port-forwarding"
  default_extensions = {
    permit-pty = ""
  }
  default_user = "ubuntu"
  ttl          = "1800"
}

output "ssh_ca_cert" {
  value = vault_ssh_secret_backend_ca.ca.public_key
}
