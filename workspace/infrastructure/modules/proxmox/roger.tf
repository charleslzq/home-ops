locals {
  nomad_servers = [
    {
      ip           = "10.10.30.210"
      proxmox_node = "avalon"
    },
    {
      ip           = "10.10.30.211"
      proxmox_node = "skypiea"
    },
    {
      ip           = "10.10.30.212"
      proxmox_node = "skypiea"
    }
  ]
}

module "roger" {
  depends_on = [
    module.rayleigh
  ]
  count = length(local.nomad_servers)

  source                  = "./modules/nomad_server"
  vm_name                 = "roger-${count.index + 1}"
  proxmox_node            = local.nomad_servers[count.index].proxmox_node
  consul_version          = local.consul_version
  consul_template_version = local.consul_template_version
  nomad_version           = local.nomad_version
  cifs_config             = module.cifs.cloud_init_config
  server_ip_list          = local.consul_server_ip_list
  ip                      = local.nomad_servers[count.index].ip
  gateway                 = local.gateway
  ssh_ca_cert             = var.ssh_ca_cert
}
