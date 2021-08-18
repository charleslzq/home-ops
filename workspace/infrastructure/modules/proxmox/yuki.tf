data "vault_generic_secret" "vault_settings" {
  path = "secret/home/yuki"
}

locals {
  vaults           = jsondecode(nonsensitive(data.vault_generic_secret.vault_settings.data.vaults))
  vault_virtual_ip = "10.10.30.120"
  vault_router_id  = 2
}

module "vault_consul_config" {
  count = length(local.vaults)

  source         = "./modules/configs/consul_client"
  consul_version = local.consul_version
  encrypt_key    = data.vault_generic_secret.consul_config.data.encrypt_key
  ca_cert        = data.vault_generic_secret.consul_config.data.ca_cert
  cert           = local.vaults[count.index].cert
  key            = local.vaults[count.index].key
  ip             = local.vaults[count.index].ip
  server_ip_list = local.consul_server_ip_list
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
