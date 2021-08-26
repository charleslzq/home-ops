module "nomad_vault_integration" {
  depends_on = [
    vault_pki_secret_backend_intermediate_set_signed.intermediate,
    module.consul_template_vault_integration,
  ]

  source            = "./modules/nomad_vault"
  vault_address     = local.vault_address
  vault_int_ca_path = vault_pki_secret_backend.pki_int.path
  nomad_servers     = local.nomad_servers
  nomad_clients     = local.nomad_clients
}
