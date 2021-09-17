locals {
  nas = [{
    ip   = "10.10.30.180"
    name = "shanks"
  }]
}

module "shanks" {
  source = "./modules/worker"

  vm_name                 = local.nas[0].name
  proxmox_node            = "avalon"
  cifs_config             = module.cifs.cloud_init_config
  consul_template_version = local.consul_template_version
  consul_version          = local.consul_version
  nomad_version           = local.nomad_version
  gateway                 = "10.10.30.1"
  ip                      = local.nas[0].ip
  server_ip_list          = local.consul_server_ip_list
  ssh_ca_cert             = var.ssh_ca_cert
  cores                   = 2
  sockets                 = "2"
  memory                  = 4096
  disk_size               = "1000G"
  storage                 = "zfs1"
  node_type               = "nas"
}
