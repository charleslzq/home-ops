module "consul_template_vault_integration" {
  source = "./modules/consul_template_vault"

  vault_address = "http://10.10.30.121:8200"
  servers       = local.all_servers
}
