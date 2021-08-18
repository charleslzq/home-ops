data "local_file" "pihole_conf" {
  filename = "${path.module}/files/pihole.conf"
}

locals {
  file_content = templatefile("${path.module}/files/cloud-init.yml.tpl", {
    pihole_conf = indent(6, data.local_file.pihole_conf.content)
    pihole_env = indent(6, templatefile("${path.module}/files/pihole.env.tpl", {
      hostname     = var.hostname
      web_password = var.web_password
      ip           = var.ip
    }))
  })
}
