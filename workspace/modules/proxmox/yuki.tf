data "vault_generic_secret" "vault_settings" {
  path = "secret/home/yuki"
}

locals {
  vaults           = jsondecode(nonsensitive(data.vault_generic_secret.vault_settings.data.vaults))
  vault_virtual_ip = "10.10.30.120"
  vault_router_id  = 2
}

module "vault_keepalive_config" {
  count = length(local.vaults)

  source    = "./modules/configs/keepalived"
  ip        = local.vault_virtual_ip
  router_id = local.vault_router_id
  password  = data.vault_generic_secret.vault_settings.data.keepalive_password
  state     = local.vaults[count.index].state
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
  server_ip_list = local.server_ip_list
}

module "yuki" {
  count = length(local.vaults)

  source          = "./modules/cloud_init"
  vm_name         = "yuku-${count.index + 1}"
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
      content      = module.vault_keepalive_config[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
  disk_size = "5G"
}
