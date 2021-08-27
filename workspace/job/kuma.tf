resource "vault_policy" "kuma_policy" {
  name = "kuma_policy"

  policy = <<EOT
path "database/data/kuma" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "kuma" {
  jobspec = templatefile("${path.module}/spec/kuma.hcl", {
    policy = vault_policy.kuma_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
