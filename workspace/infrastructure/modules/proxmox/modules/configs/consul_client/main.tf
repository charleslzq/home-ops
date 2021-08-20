locals {
  file_content = templatefile("${path.module}/files/consul-init.yml.tpl", {
    consul_version = var.consul_version
    consul_config = indent(6, templatefile("${path.module}/files/consul.hcl.tpl", {
      ip             = jsonencode(var.ip)
      server_ip_list = jsonencode(var.server_ip_list)
    }))
  })
}

output "cloud_init_config" {
  value = local.file_content
}