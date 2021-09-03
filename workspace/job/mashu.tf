resource "vault_policy" "mashu_policy" {
  name = "mashu_policy"

  policy = <<EOT
path "database/data/mashu" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "mashu" {
  jobspec = templatefile("${path.module}/spec/mashu.hcl", {
    policy = vault_policy.mashu_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
