locals {
  file_content = templatefile("${path.module}/files/consul-init.yml.tpl", {
    consul_version = var.consul_version
    consul_ca      = indent(6, var.ca_cert)
    consul_cert    = indent(6, var.cert)
    consul_key     = indent(6, var.key)
    consul_config = indent(6, templatefile("${path.module}/files/consul.hcl.tpl", {
      encrypt_key    = jsonencode(var.encrypt_key)
      ip             = jsonencode(var.ip)
      server_ip_list = jsonencode(var.server_ip_list)
    }))
  })
}

output "cloud_init_config" {
  value = local.file_content
}