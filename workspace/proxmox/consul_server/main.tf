data "vault_generic_secret" "cifs_settings" {
  path = "secret/home/cifs"
}

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/../files/cloud-init.yml.tpl", {
      ssh_ca_pub_key = var.ssh_ca_cert
      host_name      = var.vm_name
      cifs_path      = data.vault_generic_secret.cifs_settings.data.path
      cifs_username  = data.vault_generic_secret.cifs_settings.data.username
      cifs_password  = data.vault_generic_secret.cifs_settings.data.password
    })
    merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
  }

  part {
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
}

module "cloud-init-vm" {
  source = "../cloud_init"

  vm_name            = var.vm_name
  proxmox_node       = var.proxmox_node
  cloud_init_content = data.cloudinit_config.config.rendered
  cloud_ip_config    = "ip=${var.ip}/24,gw=${var.gateway}"
}