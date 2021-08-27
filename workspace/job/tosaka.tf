resource "vault_policy" "tosaka_policy" {
  name = "tosaka_policy"

  policy = <<EOT
path "home/data/default" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "tosaka" {
  jobspec = templatefile("${path.module}/spec/tosaka.hcl", {
    policy = vault_policy.tosaka_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
