resource "vault_policy" "backup_policy" {
  name = "backup_policy"

  policy = <<EOT
path "consul/creds/consul-server-role" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "backup-daily" {
  jobspec = templatefile("${path.module}/spec/backup.hcl.tpl", {
    backup_script = file("${path.module}/script/backup_consul.sh")
    policy        = vault_policy.backup_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
