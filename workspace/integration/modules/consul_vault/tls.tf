resource "vault_pki_secret_backend_role" "consul" {
  backend          = var.vault_int_ca_path
  name             = "consul-cluster"
  max_ttl          = 720 * 3600
  require_cn       = false
  generate_lease   = true
  allowed_domains  = ["rayleigh.consul"]
  allow_subdomains = true
}

resource "vault_pki_secret_backend_config_urls" "config_urls" {
  backend                 = var.vault_int_ca_path
  issuing_certificates    = ["https://10.10.30.120:8200/v1/pki/ca"]
  crl_distribution_points = ["https://10.10.30.120:8200/v1/pki/crl"]
}

data "local_file" "consul_server_tls_config" {
  filename = "${path.module}/files/server/tls.hcl"
}

data "local_file" "consul_client_tls_config" {
  filename = "${path.module}/files/client/tls.hcl"
}

data "local_file" "consul_server_crt" {
  filename = "${path.module}/files/server/agent.crt.tpl"
}

data "local_file" "consul_server_key" {
  filename = "${path.module}/files/server/agent.key.tpl"
}

data "local_file" "consul_server_ca" {
  filename = "${path.module}/files/server/ca.crt.tpl"
}

data "local_file" "consul_client_crt" {
  filename = "${path.module}/files/client/agent.crt.tpl"
}

data "local_file" "consul_client_key" {
  filename = "${path.module}/files/client/agent.key.tpl"
}

data "local_file" "consul_client_ca" {
  filename = "${path.module}/files/client/ca.crt.tpl"
}

data "local_file" "consul_template_config" {
  filename = "${path.module}/files/consul_template.hcl"
}

resource "null_resource" "consul_tls_server_certs" {
  depends_on = [
    null_resource.consul_gossip
  ]
  count = length(var.consul_servers)
  triggers = {
    template_config = data.local_file.consul_template_config.content,
    tls_config      = data.local_file.consul_server_tls_config.content
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.consul_servers[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = data.local_file.consul_server_tls_config.content
    destination = "~/20.tls.hcl"
  }
  provisioner "file" {
    content     = data.local_file.consul_server_crt.content
    destination = "~/agent.crt.tpl"
  }
  provisioner "file" {
    content     = data.local_file.consul_server_key.content
    destination = "~/agent.key.tpl"
  }
  provisioner "file" {
    content     = data.local_file.consul_server_ca.content
    destination = "~/ca.crt.tpl"
  }
  provisioner "file" {
    content     = data.local_file.consul_template_config.content
    destination = "~/20.consul.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/consul/agent-certs/",
      "sudo chown consul:consul /opt/consul/agent-certs",
      "sudo chmod 755 /opt/consul/agent-certs/",
      "sudo mkdir -p /opt/consul/templates/",
      "sudo mv ~/20.consul.hcl /etc/consul_template.d/",
      "sudo mv ~/*.tpl /opt/consul/templates",
      "sudo mv ~/20.tls.hcl /etc/consul.d/",
      "sudo systemctl restart consul_template",
      "sudo systemctl restart consul",
    ]
  }
}

resource "null_resource" "consul_tls_client_certs" {
  depends_on = [
    null_resource.consul_gossip,
    null_resource.consul_tls_server_certs,
  ]
  count = length(var.consul_clients)
  triggers = {
    template_config = data.local_file.consul_template_config.content,
    tls_config      = data.local_file.consul_client_tls_config.content
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.consul_clients[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = data.local_file.consul_client_tls_config.content
    destination = "~/20.tls.hcl"
  }
  provisioner "file" {
    content     = data.local_file.consul_client_crt.content
    destination = "~/agent.crt.tpl"
  }
  provisioner "file" {
    content     = data.local_file.consul_client_key.content
    destination = "~/agent.key.tpl"
  }
  provisioner "file" {
    content     = data.local_file.consul_client_ca.content
    destination = "~/ca.crt.tpl"
  }
  provisioner "file" {
    content     = data.local_file.consul_template_config.content
    destination = "~/20.consul.hcl"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/consul/agent-certs/",
      "sudo chown consul:consul /opt/consul/agent-certs",
      "sudo chmod 755 /opt/consul/agent-certs/",
      "sudo mkdir -p /opt/consul/templates/",
      "sudo mv ~/20.consul.hcl /etc/consul_template.d/",
      "sudo mv ~/*.tpl /opt/consul/templates",
      "sudo mv ~/20.tls.hcl /etc/consul.d/",
      "sudo systemctl restart consul_template",
      "sudo systemctl restart consul",
    ]
  }
}
