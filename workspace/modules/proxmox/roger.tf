data "vault_generic_secret" "nomad_config" {
  path = "secret/home/roger"
}

locals {
  nomad_servers = jsondecode(nonsensitive(data.vault_generic_secret.nomad_config.data.servers))
}

module "roger" {
  depends_on = [
    module.rayleigh
  ]
  count = length(local.nomad_servers)

  source         = "./modules/nomad_server"
  vm_name        = "roger-${count.index + 1}"
  proxmox_node   = local.nomad_servers[count.index].proxmox_node
  consul_version = local.consul_version
  nomad_version  = local.nomad_version
  cifs_config    = module.cifs.cloud_init_config
  server_ip_list = local.consul_server_ip_list
  ip             = local.nomad_servers[count.index].ip
  gateway        = data.vault_generic_secret.consul_config.data.gateway
  ssh_ca_cert    = var.ssh_ca_cert
}
