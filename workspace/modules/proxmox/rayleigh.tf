locals {
  consul_servers = [
    {
      ip           = "10.10.30.99"
      proxmox_node = "avalon"
    },
    {
      ip           = "10.10.30.100"
      proxmox_node = "skypiea"
    },
    {
      ip           = "10.10.30.101"
      proxmox_node = "skypiea"
    },
  ]
  consul_server_ip_list = local.consul_servers.*.ip
}

module "rayleigh" {
  count = length(local.consul_servers)

  source         = "./modules/consul_server"
  vm_name        = "rayleigh-${count.index + 1}"
  proxmox_node   = local.consul_servers[count.index].proxmox_node
  consul_version = local.consul_version
  cifs_config    = module.cifs.cloud_init_config
  server_ip_list = local.consul_server_ip_list
  ip             = local.consul_servers[count.index].ip
  gateway        = local.gateway
  ssh_ca_cert    = var.ssh_ca_cert
}
