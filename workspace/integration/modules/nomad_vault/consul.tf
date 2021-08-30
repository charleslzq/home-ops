resource "consul_acl_policy" "server_consul_policy" {
  name        = "service-nomad"
  rules       = file("${path.module}/files/server/consul_policy.hcl")
  datacenters = ["rayleigh"]
}

resource "consul_acl_policy" "client_consul_policy" {
  name        = "service-nomad-client"
  rules       = file("${path.module}/files/client/consul_policy.hcl")
  datacenters = ["rayleigh"]
}

resource "consul_acl_token" "nomad_token" {
  count    = length(var.nomad_servers)
  policies = [consul_acl_policy.server_consul_policy.name]
  local    = true
}

data "consul_acl_token_secret_id" "nomad_read" {
  count       = length(var.nomad_servers)
  accessor_id = consul_acl_token.nomad_token[count.index].id
}

resource "consul_acl_token" "nomad_client_token" {
  count    = length(var.nomad_clients)
  policies = [consul_acl_policy.client_consul_policy.name]
  local    = true
}

data "consul_acl_token_secret_id" "nomad_client_read" {
  count       = length(var.nomad_clients)
  accessor_id = consul_acl_token.nomad_client_token[count.index].id
}

resource "null_resource" "nomad_consul_server_config" {
  count = length(var.nomad_servers)
  triggers = {
    token = data.consul_acl_token_secret_id.nomad_read[count.index].secret_id
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.nomad_servers[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content = templatefile("${path.module}/files/consul.hcl.tpl", {
      token = data.consul_acl_token_secret_id.nomad_read[count.index].secret_id
    })
    destination = "~/consul.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/consul.hcl /etc/nomad.d/",
      "sudo systemctl restart nomad"
    ]
  }
}

resource "null_resource" "nomad_consul_client_config" {
  count = length(var.nomad_clients)
  triggers = {
    token = data.consul_acl_token_secret_id.nomad_client_read[count.index].secret_id
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.nomad_clients[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content = templatefile("${path.module}/files/consul.hcl.tpl", {
      token = data.consul_acl_token_secret_id.nomad_client_read[count.index].secret_id
    })
    destination = "~/consul.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/consul.hcl /etc/nomad.d/",
      "sudo systemctl restart nomad"
    ]
  }
}
