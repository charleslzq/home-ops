resource "vault_policy" "backup_policy" {
  name = "backup_policy"

  policy = <<EOT
path "consul/creds/consul-server-role" {
  capabilities = ["read"]
}
path "database/data/odysseus" {
  capabilities = ["read"]
}
path "database/data/mashu" {
  capabilities = ["read"]
}
path "database/data/shanks" {
  capabilities = ["read"]
}
path "database/data/shouko" {
  capabilities = ["read"]
}
path "database/data/riza" {
  capabilities = ["read"]
}
path "database/data/darjeeling" {
  capabilities = ["read"]
}
path "database/data/robin" {
  capabilities = ["read"]
}
path "database/data/sanji" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "backup-daily" {
  jobspec = templatefile("${path.module}/spec/backup.hcl", {
    backup_consul_script    = file("${path.module}/script/backup_consul.sh")
    backup_postgres_script  = file("${path.module}/script/backup_postgres.sh")
    backup_sqlite_script    = file("${path.module}/script/backup_sqlite.sh")
    backup_directory_script = file("${path.module}/script/backup_directory.sh")
    policy                  = vault_policy.backup_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
