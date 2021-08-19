module "traefik_consul_client" {
  source = "../configs/consul_client"

  server_ip_list = var.server_ip_list
  ip             = var.ip
  consul_version = var.consul_version
}

module "traefik_nomad_client" {
  source = "../configs/nomad_client"

  nomad_version = var.nomad_version
  node_type     = "gateway"
}

module "traefik_keepalive_config" {
  source = "../configs/keepalived"

  ip        = var.keepalive_virtual_ip
  router_id = var.keepalive_router_id
  password  = var.keepalive_password
  state     = var.keepalive_state
}

data "local_file" "traefik_config" {
  filename = "${path.module}/files/traefik.yml"
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
      content      = module.traefik_consul_client.cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.traefik_nomad_client.cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content = templatefile("${path.module}/files/cloud-init.yml.tpl", {
        traefik_version = var.traefik_version
        traefik_config  = indent(6, data.local_file.traefik_config.content)
      })
      merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content      = module.traefik_keepalive_config.cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
  disk_size = "5G"
}
