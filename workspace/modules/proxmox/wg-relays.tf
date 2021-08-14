data "vault_generic_secret" "wg_settings" {
  path = "secret/home/wg"
}

locals {
  relays           = jsondecode(nonsensitive(data.vault_generic_secret.wg_settings.data.relays))
  relay_virtual_ip = "10.10.30.32"
  relay_router_id  = 1
}

module "wg_config" {
  count  = length(local.relays)
  source = "./modules/wg-config"

  address     = local.relays[count.index].address
  private_key = local.relays[count.index].private_key
  post_up     = "iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE;iptables -A FORWARD -o %i -j ACCEPT; sysctl -w net.ipv4.ip_forward=1; sysctl -w net.ipv6.conf.all.forwarding=1"
  post_down   = "iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE;iptables -D FORWARD -o %i -j ACCEPT; sysctl -w net.ipv4.ip_forward=0; sysctl -w net.ipv6.conf.all.forwarding=0"
  peers       = local.relays[count.index].peers
}

module "wg_keepalive_config" {
  count = length(local.relays)

  source    = "./modules/keepalived-config"
  ip        = local.relay_virtual_ip
  router_id = local.relay_router_id
  password  = data.vault_generic_secret.wg_settings.data.relay_keepalive_password
  state     = local.relays[count.index].state
}

module "wg-relays" {
  count = length(local.relays)

  source          = "./modules/cloud_init"
  vm_name         = local.relays[count.index].name
  proxmox_node    = local.relays[count.index].proxmox_node
  cloud_ip_config = "ip=${local.relays[count.index].ip}/24,gw=10.10.30.1"
  ssh_ca_cert     = var.ssh_ca_cert
  cloud_init_parts = [
    {
      content_type = "text/cloud-config"
      content      = module.wg_config[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.wg_keepalive_config[count.index].cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
  memory    = 512
  disk_size = "5G"
}