locals {
  file_content = templatefile("${path.module}/files/cloud-init.yml.tpl", {
    vault_version = var.vault_version
    vault_config = indent(6, templatefile("${path.module}/files/vault.hcl.tpl", {
      ip           = var.ip
    }))
  })
}

output "cloud_init_config" {
  value = local.file_content
}
