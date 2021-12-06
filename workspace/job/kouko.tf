resource "vault_policy" "kouko_policy" {
  name = "kouko_policy"

  policy = <<EOT
path "home/data/default" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "kouko" {
  jobspec = templatefile("${path.module}/spec/kouko.hcl", {
    policy = vault_policy.kouko_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
