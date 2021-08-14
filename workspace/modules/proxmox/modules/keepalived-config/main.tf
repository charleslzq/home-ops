locals {
  file_content = templatefile("${path.module}/cloud-init.yml.tpl", {
    state      = var.state
    ip         = var.ip
    interface  = var.interface
    advert_int = var.advert_int
    password   = var.password
    router_id  = var.router_id
    priority   = var.priority
  })
}

output "cloud_init_config" {
  value = local.file_content
}
