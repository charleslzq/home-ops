locals {
  file_content = templatefile("${path.module}/files/cloud-init.yml.tpl", {
    vault_version = var.vault_version
    vault_cert    = indent(6, var.vault_cert)
    vault_key     = indent(6, var.vault_key)
    vault_ca      = indent(6, var.vault_ca)
    vault_config = indent(6, templatefile("${path.module}/files/vault.hcl.tpl", {
      ip = var.ip
    }))
  })
}

output "cloud_init_config" {
  value = local.file_content
}
