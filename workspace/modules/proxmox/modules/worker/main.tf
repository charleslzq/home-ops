module "worker_consul_client" {
  source = "../configs/consul_client"

  server_ip_list = var.server_ip_list
  ip             = var.ip
  ca_cert        = var.ca_cert
  cert           = var.cert
  key            = var.key
  consul_version = var.consul_version
  encrypt_key    = var.encrypt_key
}

module "worker_nomad_client" {
  source = "../configs/nomad_client"

  nomad_version = var.nomad_version
  node_type     = "worker"
}

module "gateway" {
  source = "../cloud_init"

  vm_name         = var.vm_name
  proxmox_node    = var.proxmox_node
  cloud_ip_config = "ip=${var.ip}/24,gw=${var.gateway}"
  ssh_ca_cert     = var.ssh_ca_cert
  cloud_init_parts = [
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
  ]
  memory    = 4096
  disk_size = "50G"
}
