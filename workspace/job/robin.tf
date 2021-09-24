resource "vault_policy" "robin_policy" {
  name = "robin_policy"

  policy = <<EOT
path "database/data/robin" {
  capabilities = ["read"]
}
path "home/data/robin" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "robin" {
  jobspec = templatefile("${path.module}/spec/robin.hcl", {
    policy = vault_policy.robin_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
