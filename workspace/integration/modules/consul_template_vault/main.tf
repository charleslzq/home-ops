resource "vault_policy" "consul_template_policy" {
  name = "consul_template"

  policy = <<EOT
path "pki_int/issue/nomad-cluster" {
  capabilities = ["update"]
}
path "pki_int/issue/consul-cluster" {
  capabilities = ["update"]
}
EOT
}

resource "vault_token_auth_backend_role" "consul_template" {
  role_name              = "consul_template"
  orphan                 = true
  renewable              = true
  token_explicit_max_ttl = 0
  token_period           = 259200
}

resource "vault_token" "consul_template" {
  role_name = vault_token_auth_backend_role.consul_template.role_name
  policies = [
    vault_policy.consul_template_policy.name
  ]
  renewable       = true
  ttl             = "72h"
  renew_min_lease = 43200
  renew_increment = 86400
  no_parent       = true
}

locals {
  vault_config = templatefile("${path.module}/vault.hcl.tpl", {
    vault_address = var.vault_address
    vault_token   = vault_token.consul_template.client_token
  })
}

resource "null_resource" "consul_template_vault_config" {
  count = length(var.servers)
  triggers = {
    file_content = local.vault_config
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.servers[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = local.vault_config
    destination = "~/10.vault.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/10.vault.hcl /etc/consul_template.d/",
      "sudo systemctl reload consul_template"
    ]
  }
}
