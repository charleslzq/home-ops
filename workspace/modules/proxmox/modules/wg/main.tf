module "cloud-init-vm" {
  source = "../cloud_init"

  vm_name         = var.vm_name
  proxmox_node    = var.proxmox_node
  cloud_ip_config = "ip=${var.ip}/24,gw=${var.gateway}"
  ssh_ca_cert     = var.ssh_ca_cert
  cloud_init_parts = [
    {
      content_type = "text/cloud-config"
      content = emplatefile("${path.module}/wg.conf.tpl", {
        address     = var.address
        private_key = var.private_key
        post_up     = var.post_up
        post_down   = var.post_down
        listen_port = var.listen_port
        peers       = var.peers
      })
      merge_type = "list(append) + dict(no_replace, recurse_list) + str()"
    }
  ]
}