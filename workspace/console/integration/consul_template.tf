module "consul_template_vault_integration" {
  source = "./modules/consul_template_vault"

  vault_address = local.vault_address
  servers       = local.all_servers
}
