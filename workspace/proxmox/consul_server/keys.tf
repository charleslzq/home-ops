data "vault_generic_secret" "ssh_ca" {
  path = "vm-client-signer/config/ca"
}

data "vault_generic_secret" "consul_config" {
  path = "secret/home/consul"
}

resource "vault_pki_secret_backend" "consul" {
  path                      = "consul"
  default_lease_ttl_seconds = 3600 * 86000
  max_lease_ttl_seconds     = 3600 * 86400
}

resource "vault_pki_secret_backend_root_cert" "consul" {
  depends_on = [vault_pki_secret_backend.consul]

  backend = vault_pki_secret_backend.consul.path

  type                 = "internal"
  common_name          = "Root Consul CA"
  ttl                  = 3600 * 85000
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "My OU"
  organization         = "My Home"
}

resource "vault_pki_secret_backend_role" "consul" {
  backend          = vault_pki_secret_backend.consul.path
  name             = "consul"
  ttl              = 3600 * 84000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["zenq.me"]
  allow_subdomains = true
  generate_lease   = true
}

resource "vault_pki_secret_backend_cert" "consul" {
  depends_on = [vault_pki_secret_backend_role.consul]

  backend = vault_pki_secret_backend.consul.path
  name    = vault_pki_secret_backend_role.consul.name

  common_name = var.domain
}
