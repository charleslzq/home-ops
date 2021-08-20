locals {
  vault_address = "https://yuki.zenq.me"
}

resource "vault_pki_secret_backend" "pki" {
  path                  = "pki"
  max_lease_ttl_seconds = 87600 * 3600
}

resource "vault_pki_secret_backend_root_cert" "root" {
  depends_on = [
    vault_pki_secret_backend.pki
  ]
  backend = vault_pki_secret_backend.pki.path

  type        = "internal"
  common_name = "Root PKI CA"
  ttl         = 87600 * 3600
}

resource "vault_pki_secret_backend" "pki_int" {
  path                  = "pki_int"
  max_lease_ttl_seconds = 43800 * 3600
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  depends_on = [
    vault_pki_secret_backend.pki_int
  ]
  backend = vault_pki_secret_backend.pki_int.path

  type        = "internal"
  common_name = "Intermediate PKI"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  depends_on = [
    vault_pki_secret_backend_intermediate_cert_request.intermediate
  ]
  backend = vault_pki_secret_backend.pki.path

  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  ttl         = 43800 * 3600
  common_name = "Intermediate CA"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_pki_secret_backend.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}
