locals {
  tosaka_virtual_ip = "10.10.30.235"
  tosaka_router_id  = 2
  masters = [
    {
      hostname = "rin"
      node     = "skypiea"
      ip       = "10.10.30.234"
      state    = "MASTER"
    },
    {
      hostname = "sakura"
      node     = "avalon"
      ip       = "10.10.30.236"
      state    = "BACKUP"
    }
  ]
}

module "tosaka_keepalive_config" {
  count = length(local.masters)

  source    = "./modules/configs/keepalived"
  ip        = local.tosaka_virtual_ip
  router_id = local.tosaka_router_id
  password  = data.vault_generic_secret.keepalived_passwords.data.tosaka
  state     = local.masters[count.index].state
}

module "tosaka" {
  count = length(local.masters)

  source                  = "./modules/worker"
  vm_name                 = local.masters[count.index].hostname
  proxmox_node            = local.masters[count.index].node
  cifs_config             = module.cifs.cloud_init_config
  consul_version          = local.consul_version
  consul_template_version = local.consul_template_version
  nomad_version           = local.nomad_version
  server_ip_list          = local.consul_server_ip_list
  gateway                 = "10.10.30.1"
  ip                      = local.masters[count.index].ip
  ssh_ca_cert             = var.ssh_ca_cert
  node_type               = "dns"
  additional_cloud_init_config = [
    {
      content_type = "text/cloud-config"
      content      = module.tosaka_keepalive_config[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
  memory    = 1024
  disk_size = "10G"
}
