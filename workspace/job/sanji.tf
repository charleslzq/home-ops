resource "vault_policy" "sanji_policy" {
  name = "sanji_policy"

  policy = <<EOT
path "database/data/sanji" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "sanji" {
  jobspec = templatefile("${path.module}/spec/sanji.hcl", {
    policy = vault_policy.sanji_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
