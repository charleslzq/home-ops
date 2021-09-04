resource "vault_policy" "shanks_policy" {
  name = "shanks_policy"

  policy = <<EOT
path "database/data/shanks" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "shanks" {
  jobspec = templatefile("${path.module}/spec/shanks.hcl", {
    policy = vault_policy.shanks_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
