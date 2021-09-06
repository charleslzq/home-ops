resource "vault_policy" "riza_policy" {
  name = "riza_policy"

  policy = <<EOT
path "database/data/riza" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "riza" {
  jobspec = templatefile("${path.module}/spec/riza.hcl", {
    policy = vault_policy.riza_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
