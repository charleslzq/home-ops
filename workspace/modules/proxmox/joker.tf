locals {
  joker_nodes = [
    {
      ip           = "10.10.30.111"
      proxmox_node = "avalon"
      state        = "MASTER"
    },
    {
      ip           = "10.10.30.112"
      proxmox_node = "skypiea"
      state        = "BACKUP"
    }
  ]
}

module "joker" {
  depends_on = [
    module.rayleigh,
    module.roger,
  ]
  count = length(local.joker_nodes)

  source               = "./modules/gateway"
  vm_name              = "joker-${count.index + 1}"
  proxmox_node         = local.joker_nodes[count.index].proxmox_node
  ip                   = local.joker_nodes[count.index].ip
  gateway              = local.gateway
  ssh_ca_cert          = var.ssh_ca_cert
  cifs_config          = module.cifs.cloud_init_config
  consul_version       = local.consul_version
  nomad_version        = local.nomad_version
  traefik_version      = local.traefik_version
  server_ip_list       = local.consul_server_ip_list
  keepalive_password   = data.vault_generic_secret.keepalived_passwords.data.joker
  keepalive_router_id  = 3
  keepalive_virtual_ip = "10.10.30.110"
  keepalive_state      = local.joker_nodes[count.index].state
}
