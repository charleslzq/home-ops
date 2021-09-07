resource "vault_policy" "darjeeling_policy" {
  name = "darjeeling_policy"

  policy = <<EOT
path "database/data/darjeeling" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "darjeeling" {
  jobspec = templatefile("${path.module}/spec/darjeeling.hcl", {
    policy = vault_policy.darjeeling_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
