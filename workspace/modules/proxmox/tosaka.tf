data "vault_generic_secret" "default" {
  path = "secret/home/default"
}

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

module "servents" {
  count = length(local.masters)

  source       = "./modules/configs/pihole"
  hostname     = local.masters[count.index].hostname
  web_password = data.vault_generic_secret.default.data.password
  ip           = local.masters[count.index].ip
}

module "tosaka" {
  depends_on = [
    module.servents
  ]
  count = length(local.masters)

  source          = "./modules/cloud_init"
  vm_name         = local.masters[count.index].hostname
  proxmox_node    = local.masters[count.index].node
  cloud_ip_config = "ip=${local.masters[count.index].ip}/24,gw=10.10.30.1"
  ssh_ca_cert     = var.ssh_ca_cert
  cloud_init_parts = [
    {
      content_type = "text/cloud-config"
      content      = module.servents[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.tosaka_keepalive_config[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
  memory    = 512
  disk_size = "5G"
}
