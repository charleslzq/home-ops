resource "vault_policy" "connect_policy" {
  name = "connect_policy"

  policy = <<EOT
path "/sys/mounts" {
  capabilities = [ "read" ]
}

path "/sys/mounts/connect_root" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "/sys/mounts/connect_inter" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "/connect_root/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "/connect_inter/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
EOT
}

resource "vault_token_auth_backend_role" "consul_connect" {
  role_name              = "consul_connect"
  orphan                 = true
  renewable              = true
  token_explicit_max_ttl = 0
  token_period           = 259200
}

resource "vault_token" "consul_connect" {
  role_name = vault_token_auth_backend_role.consul_connect.role_name
  policies = [
    vault_policy.connect_policy.name
  ]
  renewable       = true
  ttl             = "72h"
  renew_min_lease = 43200
  renew_increment = 86400
  no_parent       = true
}

locals {
  connect_config = templatefile("${path.module}/files/connect.hcl.tpl", {
    vault_token = vault_token.consul_connect.client_token
  })
}

resource "null_resource" "connect_config" {
  count = length(local.all)
  triggers = {
    connect_config = local.connect_config
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = local.all[count.index].ip
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = local.connect_config
    destination = "~/30.connect.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/30.connect.hcl /etc/consul.d/",
      "sudo systemctl restart consul",
    ]
  }
}
