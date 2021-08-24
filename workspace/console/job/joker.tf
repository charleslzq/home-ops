resource "vault_policy" "joker_policy" {
  name = "joker_policy"

  policy = <<EOT
path "https/data/me/zenq" {
  capabilities = ["read"]
}
EOT
}

resource "nomad_job" "joker" {
  jobspec = templatefile("${path.module}/spec/traefik.hcl.tpl", {
    traefik_version = "2.5.1"
    policy          = vault_policy.joker_policy.name
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
