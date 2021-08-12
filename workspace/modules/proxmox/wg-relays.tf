data "vault_generic_secret" "wg_settings" {
  path = "secret/home/wg"
}

locals {
  relays = jsondecode(nonsensitive(data.vault_generic_secret.wg_settings.data.relays))
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

module "cloud-init-vm" {
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
    }
  ]
}