data "vault_generic_secret" "cifs_settings" {
  path = "secret/home/cifs"
}

locals {
  file_content = templatefile("${path.module}/cloud-init.yml.tpl", {
    cifs_path     = data.vault_generic_secret.cifs_settings.data.path
    cifs_username = data.vault_generic_secret.cifs_settings.data.username
    cifs_password = data.vault_generic_secret.cifs_settings.data.password
  })
}

output "cloud_init_config" {
  value = local.file_content
}
