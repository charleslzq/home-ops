data "vault_generic_secret" "default" {
  path = "secret/home/default"
}

locals {
  masters = [
    {
      hostname = "rin"
      node     = "skypiea"
      ip       = "10.10.30.235"
    },
    {
      hostname = "sakura"
      node     = "avalon"
      ip       = "10.10.30.236"
    }
  ]
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
    }
  ]
  memory    = 512
  disk_size = "5G"
}
