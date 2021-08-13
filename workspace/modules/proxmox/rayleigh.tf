terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

data "vault_generic_secret" "consul_config" {
  path = "secret/home/consul"
}

locals {
  servers        = jsondecode(nonsensitive(data.vault_generic_secret.consul_config.data.servers))
  server_ip_list = local.servers.*.ip
}

module "rayleigh" {
  count = length(local.servers)

  source         = "./modules/consul_server"
  vm_name        = "rayleigh-${count.index + 1}"
  proxmox_node   = local.servers[count.index].proxmox_node
  consul_version = "1.10.1"
  nomad_version = "1.1.3"
  cifs_config    = module.cifs.cloud_init_config
  server_ip_list = local.server_ip_list
  ip             = local.servers[count.index].ip
  gateway        = data.vault_generic_secret.consul_config.data.gateway
  encrypt_key    = data.vault_generic_secret.consul_config.data.encrypt_key
  ca_cert        = data.vault_generic_secret.consul_config.data.ca_cert
  ssh_ca_cert    = var.ssh_ca_cert
  cert           = local.servers[count.index].cert
  key            = local.servers[count.index].key
  domain         = "rayleigh.zenq.me"
}
