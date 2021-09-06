resource "vault_policy" "joker_policy" {
  name = "joker_policy"

  policy = <<EOT
path "https/data/me/zenq" {
  capabilities = ["read"]
}
path "oidc/shouko/data/yashin" {
  capabilities = ["read"]
}
EOT
}

resource "consul_acl_policy" "joker_policy" {
  provider    = consul.home
  name        = "service_joker"
  rules       = <<EOT
service "joker" {
  policy = "write"
}
service "joker-sidecar-proxy" {
  policy = "write"
}
service "traefik" {
  policy = "write"
}
service "traefik-sidecar-proxy" {
  policy = "write"
}
service_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "read"
}
EOT
  datacenters = ["rayleigh"]
}

resource "consul_acl_token" "joker_token" {
  provider = consul.home
  policies = [consul_acl_policy.joker_policy.name]
  local    = true
}

data "consul_acl_token_secret_id" "read" {
  provider    = consul.home
  accessor_id = consul_acl_token.joker_token.id
}

data "local_file" "ca_file" {
  filename = "/usr/local/share/ca-certificates/extra/ca.crt"
}

resource "nomad_job" "joker" {
  jobspec = templatefile("${path.module}/spec/traefik.hcl", {
    traefik_version = "2.5.1"
    policy          = vault_policy.joker_policy.name
    ca              = data.local_file.ca_file.content
    consul_token    = data.consul_acl_token_secret_id.read.secret_id
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
