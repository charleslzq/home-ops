locals {
  classes = [
    {
      ip           = "10.10.30.50"
      proxmox_node = "avalon"
      name         = "2c"
    },
    {
      ip           = "10.10.30.51"
      proxmox_node = "avalon"
      name         = "2d"
    },
    {
      ip           = "10.10.30.52"
      proxmox_node = "skypiea"
      name         = "1d"
    }
  ]
}

module "yagami" {
  depends_on = [
    module.rayleigh,
    module.roger
  ]
  count = length(local.classes)

  source = "./modules/worker"

  cifs_config             = module.cifs.cloud_init_config
  consul_version          = local.consul_version
  consul_template_version = local.consul_template_version
  nomad_version           = local.nomad_version
  server_ip_list          = local.consul_server_ip_list
  gateway                 = "10.10.30.1"
  ssh_ca_cert             = var.ssh_ca_cert
  vm_name                 = local.classes[count.index].name
  proxmox_node            = local.classes[count.index].proxmox_node
  ip                      = local.classes[count.index].ip
}
