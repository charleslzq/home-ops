data "vault_generic_secret" "consul_config" {
  path = "secret/home/rayleigh"
}

locals {
  consul_servers        = jsondecode(nonsensitive(data.vault_generic_secret.consul_config.data.servers))
  consul_server_ip_list = local.consul_servers.*.ip
}

module "rayleigh" {
  count = length(local.consul_servers)

  source         = "./modules/consul_server"
  vm_name        = "rayleigh-${count.index + 1}"
  proxmox_node   = local.consul_servers[count.index].proxmox_node
  consul_version = local.consul_version
  cifs_config    = module.cifs.cloud_init_config
  server_ip_list = local.consul_server_ip_list
  ip             = local.consul_servers[count.index].ip
  gateway        = data.vault_generic_secret.consul_config.data.gateway
  ssh_ca_cert    = var.ssh_ca_cert
}
