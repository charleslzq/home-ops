locals {
  file_content = templatefile("${path.module}/files/cloud-init.yml.tpl", {
    wireguard_config = indent(6, templatefile("${path.module}/files/wg.conf.tpl", {
      address     = var.address
      private_key = var.private_key
      post_up     = var.post_up
      post_down   = var.post_down
      listen_port = var.listen_port
      dns         = var.dns
      peers       = var.peers
    }))
  })
}

output "cloud_init_config" {
  value = local.file_content
}