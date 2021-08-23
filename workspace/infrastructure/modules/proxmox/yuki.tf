locals {
  vaults = [
    {
      ip           = "10.10.30.121"
      proxmox_node = "avalon"
    },
    {
      ip           = "10.10.30.122"
      proxmox_node = "skypiea"
    }
  ]
}

module "vault_consul_config" {
  count = length(local.vaults)

  source                  = "./modules/configs/consul_client"
  consul_version          = local.consul_version
  consul_template_version = local.consul_template_version
  ip                      = local.vaults[count.index].ip
  server_ip_list          = local.consul_server_ip_list
}

module "vault_config" {
  count  = 2
  source = "./modules/configs/vault"

  vault_version = local.vault_version
  ip            = local.vaults[count.index].ip
}

module "yuki" {
  depends_on = [
    module.rayleigh
  ]
  count = length(local.vaults)

  source          = "./modules/cloud_init"
  vm_name         = "yuki-${count.index + 1}"
  proxmox_node    = local.vaults[count.index].proxmox_node
  cloud_ip_config = "ip=${local.vaults[count.index].ip}/24,gw=10.10.30.1"
  ssh_ca_cert     = var.ssh_ca_cert
  cloud_init_parts = [
    {
      content_type = "text/cloud-config"
      content      = module.cifs.cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.vault_consul_config[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.vault_config[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
  disk_size = "5G"
}
