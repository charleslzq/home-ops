resource "consul_acl_policy" "agent" {
  depends_on = [
    null_resource.consul_tls_client_certs
  ]
  count = length(var.consul_clients)
  name  = "agent-${var.consul_clients[count.index].name}"
  rules = templatefile("${path.module}/files/acl_policy.hcl.tpl", {
    name = var.consul_clients[count.index].name
  })
  datacenters = ["rayleigh"]
}

resource "consul_acl_token" "agent_token" {
  count    = length(var.consul_clients)
  policies = [consul_acl_policy.agent[count.index].name]
  local    = true
}

data "consul_acl_token_secret_id" "read" {
  count       = length(var.consul_clients)
  accessor_id = consul_acl_token.agent_token[count.index].id
}

resource "null_resource" "consul_client_acl_token" {
  count = length(var.consul_clients)
  triggers = {
    token = data.consul_acl_token_secret_id.read[count.index].secret_id
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.consul_clients[count.index].ip
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content = templatefile("${path.module}/files/acl_token.hcl.tpl", {
      token = data.consul_acl_token_secret_id.read[count.index].secret_id
    })
    destination = "~/20.acl-token.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/20.acl-token.hcl /etc/consul.d/",
      "sudo systemctl restart consul",
    ]
  }
}
