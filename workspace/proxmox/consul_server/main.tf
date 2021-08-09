data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/../files/cloud-init.yml.tpl", {
      ssh_ca_pub_key = var.ssh_ca_key
      host_name      = var.vm_name
    })
    merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/consul-init.yml.tpl", {
      consul_version = var.consul_version
      consul_ca      = indent(6, var.ca_cert)
      consul_cert    = indent(6, var.cert)
      consul_key     = indent(6, var.private_key)
      consul_config = indent(6, templatefile("${path.module}/files/consul.hcl.tpl", {
        encrypt_key = jsonencode(var.encrypt_key)
        ip = var.ip
      }))
    })
    merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
  }
}

module "cloud-init-vm" {
  source = "../cloud_init"

  vm_name            = var.vm_name
  proxmox_node       = var.proxmox_node
  cloud_init_content = data.cloudinit_config.config.rendered
  cloud_ip_config    = "ip=${var.ip},gw=${var.gateway}"
}