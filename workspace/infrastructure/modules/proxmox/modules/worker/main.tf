module "worker_consul_client" {
  source = "../configs/consul_client"

  server_ip_list          = var.server_ip_list
  ip                      = var.ip
  consul_version          = var.consul_version
  consul_template_version = var.consul_template_version
}

module "worker_nomad_client" {
  source = "../configs/nomad_client"

  nomad_version = var.nomad_version
  node_type     = var.node_type
}

module "worker" {
  source = "../cloud_init"

  vm_name         = var.vm_name
  proxmox_node    = var.proxmox_node
  cloud_ip_config = "ip=${var.ip}/24,gw=${var.gateway}"
  ssh_ca_cert     = var.ssh_ca_cert
  cloud_init_parts = concat([
    {
      content_type = "text/cloud-config"
      content      = var.cifs_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.worker_consul_client.cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.worker_nomad_client.cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ], var.additional_cloud_init_config)
  cores     = var.cores
  sockets   = var.sockets
  memory    = var.memory
  storage   = var.storage
  disk_size = var.disk_size
}
