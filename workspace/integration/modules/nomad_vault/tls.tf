resource "vault_pki_secret_backend_role" "nomad" {
  backend          = var.vault_int_ca_path
  name             = "nomad-cluster"
  max_ttl          = 86400
  require_cn       = false
  generate_lease   = true
  allowed_domains  = ["global.nomad"]
  allow_subdomains = true
}

data "local_file" "nomad_tls_config" {
  filename = "${path.module}/files/tls.hcl"
}

data "local_file" "nomad_server_crt" {
  filename = "${path.module}/files/server/agent.crt.tpl"
}

data "local_file" "nomad_server_key" {
  filename = "${path.module}/files/server/agent.key.tpl"
}

data "local_file" "nomad_server_ca" {
  filename = "${path.module}/files/server/ca.crt.tpl"
}

data "local_file" "nomad_client_crt" {
  filename = "${path.module}/files/client/agent.crt.tpl"
}

data "local_file" "nomad_client_key" {
  filename = "${path.module}/files/client/agent.key.tpl"
}

data "local_file" "nomad_client_ca" {
  filename = "${path.module}/files/client/ca.crt.tpl"
}

data "local_file" "consul_template_config" {
  filename = "${path.module}/files/consul_template.hcl"
}

resource "null_resource" "nomad_tls_server_config" {
  count = length(var.nomad_servers)
  triggers = {
    tls_config      = data.local_file.nomad_tls_config.content
    template_config = data.local_file.consul_template_config.content
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.nomad_servers[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = data.local_file.nomad_tls_config.content
    destination = "~/tls.hcl"
  }
  provisioner "file" {
    content     = data.local_file.nomad_server_crt.content
    destination = "~/agent.crt.tpl"
  }
  provisioner "file" {
    content     = data.local_file.nomad_server_key.content
    destination = "~/agent.key.tpl"
  }
  provisioner "file" {
    content     = data.local_file.nomad_server_ca.content
    destination = "~/ca.crt.tpl"
  }
  provisioner "file" {
    content     = data.local_file.consul_template_config.content
    destination = "~/20.nomad.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/nomad/agent-certs/",
      "sudo chown consul:consul /opt/nomad/agent-certs",
      "sudo chmod 755 /opt/nomad/agent-certs/",
      "sudo mkdir -p /opt/nomad/templates/",
      "sudo mv ~/tls.hcl /etc/nomad.d/",
      "sudo mv ~/20.nomad.hcl /etc/consul_template.d/",
      "sudo mv ~/*.tpl /opt/nomad/templates",
      "sudo systemctl restart consul_template",
    ]
  }
}

resource "null_resource" "nomad_tls_client_config" {
  count = length(var.nomad_clients)
  triggers = {
    tls_config      = data.local_file.nomad_tls_config.content
    template_config = data.local_file.consul_template_config.content
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.nomad_clients[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = data.local_file.nomad_tls_config.content
    destination = "~/tls.hcl"
  }
  provisioner "file" {
    content     = data.local_file.nomad_client_crt.content
    destination = "~/agent.crt.tpl"
  }
  provisioner "file" {
    content     = data.local_file.nomad_client_key.content
    destination = "~/agent.key.tpl"
  }
  provisioner "file" {
    content     = data.local_file.nomad_client_ca.content
    destination = "~/ca.crt.tpl"
  }
  provisioner "file" {
    content     = data.local_file.consul_template_config.content
    destination = "~/20.nomad.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/nomad/agent-certs/",
      "sudo chown consul:consul /opt/nomad/agent-certs",
      "sudo chmod 755 /opt/nomad/agent-certs/",
      "sudo mkdir -p /opt/nomad/templates/",
      "sudo mv ~/tls.hcl /etc/nomad.d/",
      "sudo mv ~/20.nomad.hcl /etc/consul_template.d/",
      "sudo mv ~/*.tpl /opt/nomad/templates",
      "sudo systemctl restart consul_template",
    ]
  }
}
