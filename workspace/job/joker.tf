resource "vault_policy" "joker_policy" {
  name = "joker_policy"

  policy = <<EOT
path "https/data/me/zenq" {
  capabilities = ["read"]
}
EOT
}

data "local_file" "ca_file" {
  filename = "/usr/local/share/ca-certificates/extra/ca.crt"
}

resource "nomad_job" "joker" {
  jobspec = templatefile("${path.module}/spec/traefik.hcl.tpl", {
    traefik_version = "2.5.1"
    policy          = vault_policy.joker_policy.name
    ca              = data.local_file.ca_file.content
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
