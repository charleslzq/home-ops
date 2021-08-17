data "vault_generic_secret" "joker_settings" {
  path = "secret/home/joker"
}

locals {
  joker_nodes = jsondecode(nonsensitive(data.vault_generic_secret.joker_settings.data.nodes))
}

module "joker" {
  count = length(local.joker_nodes)

  source               = "./modules/gateway"
  vm_name              = "joker-${count.index + 1}"
  proxmox_node         = local.joker_nodes[count.index].proxmox_node
  ip                   = local.joker_nodes[count.index].ip
  gateway              = "10.10.30.1"
  ssh_ca_cert          = var.ssh_ca_cert
  encrypt_key          = data.vault_generic_secret.consul_config.data.encrypt_key
  ca_cert              = data.vault_generic_secret.consul_config.data.ca_cert
  cert                 = local.joker_nodes[count.index].cert
  key                  = local.joker_nodes[count.index].key
  cifs_config          = module.cifs.cloud_init_config
  consul_version       = local.consul_version
  traefik_version      = local.traefik_version
  server_ip_list       = local.consul_server_ip_list
  keepalive_password   = data.vault_generic_secret.joker_settings.data.keepalive_password
  keepalive_router_id  = 3
  keepalive_virtual_ip = "10.10.30.110"
  keepalive_state      = local.joker_nodes[count.index].state
}
