resource "vault_policy" "kerrigan_policy" {
  name = "kerrigan_policy"

  policy = <<EOT
path "oidc/darjeeling/data/kerrigan" {
  capabilities = ["read"]
}
path "home/data/kerrigan" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "kerrigan" {
  jobspec = templatefile("${path.module}/spec/kerrigan.hcl", {
    policy = vault_policy.kerrigan_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
