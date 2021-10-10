resource "vault_policy" "odysseus_policy" {
  name = "odysseus_policy"

  policy = <<EOT
path "database/data/odysseus" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "odysseus" {
  jobspec = templatefile("${path.module}/spec/odysseus.hcl", {
    policy = vault_policy.odysseus_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
