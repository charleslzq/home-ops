locals {
  joker_nodes = [
    {
      ip           = "10.10.30.111"
      proxmox_node = "avalon"
    },
    {
      ip           = "10.10.30.112"
      proxmox_node = "skypiea"
    }
  ]
}

module "joker" {
  depends_on = [
    module.rayleigh,
    module.roger
  ]
  count = length(local.joker_nodes)

  source                  = "./modules/worker"
  vm_name                 = "joker-${count.index + 1}"
  cifs_config             = module.cifs.cloud_init_config
  consul_version          = local.consul_version
  consul_template_version = local.consul_template_version
  nomad_version           = local.nomad_version
  server_ip_list          = local.consul_server_ip_list
  gateway                 = "10.10.30.1"
  ssh_ca_cert             = var.ssh_ca_cert
  proxmox_node            = local.joker_nodes[count.index].proxmox_node
  ip                      = local.joker_nodes[count.index].ip
  node_type               = "gateway"
  memory                  = 2048
  disk_size               = "20G"
}
