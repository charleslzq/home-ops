resource "vault_policy" "backup_policy" {
  name = "backup_policy"

  policy = <<EOT
path "consul/creds/consul-server-role" {
  capabilities = ["read"]
}
path "database/data/odysseus" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "backup-daily" {
  jobspec = templatefile("${path.module}/spec/backup.hcl", {
    backup_consul_script   = file("${path.module}/script/backup_consul.sh")
    backup_postgres_script = file("${path.module}/script/backup_postgres.sh")
    policy                 = vault_policy.backup_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
