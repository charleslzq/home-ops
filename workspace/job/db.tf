resource "vault_policy" "db_policy" {
  name = "db_policy"

  policy = <<EOT
path "database/data/postgres" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "db" {
  jobspec = templatefile("${path.module}/spec/db.hcl", {
    policy = vault_policy.db_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
