resource "vault_policy" "shouko_policy" {
  name = "shouko_policy"

  policy = <<EOT
path "database/data/shouko" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "shouko" {
  jobspec = templatefile("${path.module}/spec/shouko.hcl", {
    policy = vault_policy.shouko_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
