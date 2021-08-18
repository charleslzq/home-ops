locals {
  file_content = templatefile("${path.module}/cloud-init.yml.tpl", {
    nomad_version = var.nomad_version
    node_type     = var.node_type
  })
}

output "cloud_init_config" {
  value = local.file_content
}
