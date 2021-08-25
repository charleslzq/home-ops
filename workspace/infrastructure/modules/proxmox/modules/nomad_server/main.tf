module "nomad_consul_client" {
  source = "../configs/consul_client"

  server_ip_list          = var.server_ip_list
  ip                      = var.ip
  consul_version          = var.consul_version
  consul_template_version = var.consul_template_version
}

module "nomad_server" {
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
      content      = module.nomad_consul_client.cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content = templatefile("${path.module}/files/nomad-init.yml.tpl", {
        nomad_version = var.nomad_version
      })
      merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
  cores   = 2
  sockets = "2"
  memory  = 2048
}
