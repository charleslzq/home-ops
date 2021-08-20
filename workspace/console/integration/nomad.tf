module "nomad_vault_integration" {
  source = "./modules/nomad_vault"

  vault_address     = local.vault_address
  vault_int_ca_path = vault_pki_secret_backend.pki_int.path
}
