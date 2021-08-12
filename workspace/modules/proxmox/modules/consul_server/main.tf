module "cifs" {
  source = "../cifs-config"
}

module "cloud-init-vm" {
  source = "../cloud_init"

  vm_name         = var.vm_name
  proxmox_node    = var.proxmox_node
  cloud_ip_config = "ip=${var.ip}/24,gw=${var.gateway}"
  ssh_ca_cert     = var.ssh_ca_cert
  cloud_init_parts = [
    {
      content_type = "text/cloud-config"
      content      = module.cifs.cloud_init_config
      merge_type   = "list(append) + dict(no_replace, recurse_list) + str()"
    },
    {
      content_type = "text/cloud-config"
      content = templatefile("${path.module}/files/consul-init.yml.tpl", {
        consul_version = var.consul_version
        consul_ca      = indent(6, var.ca_cert)
        consul_cert    = indent(6, var.cert)
        consul_key     = indent(6, var.key)
        consul_config = indent(6, templatefile("${path.module}/files/consul.hcl.tpl", {
          encrypt_key    = jsonencode(var.encrypt_key)
          ip             = jsonencode(var.ip)
          server_ip_list = jsonencode(var.server_ip_list)
          server_count   = length(var.server_ip_list)
        }))
      })
      merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
}