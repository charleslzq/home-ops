resource "vault_policy" "nomad_server_policy" {
  name = "nomad-server"

  policy = <<EOT
# Allow creating tokens under "nomad-cluster" token role. The token role name
# should be updated if "nomad-cluster" is not used.
path "auth/token/create/nomad-cluster" {
  capabilities = ["update"]
}

# Allow looking up "nomad-cluster" token role. The token role name should be
# updated if "nomad-cluster" is not used.
path "auth/token/roles/nomad-cluster" {
  capabilities = ["read"]
}

# Allow looking up the token passed to Nomad to validate # the token has the
# proper capabilities. This is provided by the "default" policy.
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow looking up incoming tokens to validate they have permissions to access
# the tokens they are requesting. This is only required if
# `allow_unauthenticated` is set to false.
path "auth/token/lookup" {
  capabilities = ["update"]
}

# Allow revoking tokens that should no longer exist. This allows revoking
# tokens for dead tasks.
path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}

# Allow checking the capabilities of our own token. This is used to validate the
# token upon startup.
path "sys/capabilities-self" {
  capabilities = ["update"]
}

# Allow our own token to be renewed.
path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/roles/nomad-server" {
  capabilities = ["read"]
}
path "auth/token/create/nomad-server" {
  capabilities = ["update"]
}
EOT
}

resource "vault_token_auth_backend_role" "nomad_server" {
  role_name              = "nomad_server"
  orphan                 = true
  renewable              = true
  token_explicit_max_ttl = 0
  token_period           = 259200
}

resource "vault_token" "nomad_server" {
  role_name = vault_token_auth_backend_role.nomad_server.role_name
  policies = [
    vault_policy.nomad_server_policy.name
  ]
  renewable       = true
  ttl             = "72h"
  renew_min_lease = 43200
  renew_increment = 86400
  no_parent       = true
}

resource "vault_token_auth_backend_role" "nomad_cluster" {
  role_name = "nomad-cluster"
  disallowed_policies = [
    vault_policy.nomad_server_policy.name
  ]
  orphan                 = true
  renewable              = true
  token_explicit_max_ttl = 0
  token_period           = 259200
}

locals {
  nomad_vault_server_config = templatefile("${path.module}/files/vault.server.hcl.tpl", {
    vault_address    = var.vault_address
    vault_token      = vault_token.nomad_server.client_token
    create_from_role = vault_token_auth_backend_role.nomad_cluster.role_name
  })
  nomad_vault_client_config = templatefile("${path.module}/files/vault.client.hcl.tpl", {
    vault_address = var.vault_address
  })
}

resource "null_resource" "nomad_vault_server_config" {
  count = length(local.nomad_servers)
  triggers = {
    file_content = local.nomad_vault_server_config
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = local.nomad_servers[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = local.nomad_vault_server_config
    destination = "~/vault.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/vault.hcl /etc/nomad.d/",
      "sudo systemctl restart nomad"
    ]
  }
}

resource "null_resource" "nomad_vault_client_config" {
  count = length(local.nomad_clients)
  triggers = {
    file_content = local.nomad_vault_client_config
  }
  // use generate_ssh_keys.sh to update certificate
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = local.nomad_clients[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = local.nomad_vault_client_config
    destination = "~/vault.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/vault.hcl /etc/nomad.d/",
      "sudo systemctl restart nomad"
    ]
  }
}
