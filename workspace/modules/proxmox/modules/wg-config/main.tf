output "cloud-init-config" {
  value = templatefile("${path.module}/cloud-init.yml.tpl", {
    wireguard_config = templatefile("${path.module}/wg.conf.tpl", {
        address     = var.address
        private_key = var.private_key
        post_up     = var.post_up
        post_down   = var.post_down
        listen_port = var.listen_port
        peers       = var.peers
      })
  })
}