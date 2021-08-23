resource "vault_pki_secret_backend_role" "nomad" {
  backend          = var.vault_int_ca_path
  name             = "nomad-cluster"
  max_ttl          = 86400
  require_cn       = false
  generate_lease   = true
  allowed_domains  = ["global.nomad"]
  allow_subdomains = true
}

resource "vault_pki_secret_backend_cert" "nomad_server" {
  count = length(local.nomad_servers)

  depends_on = [
    vault_pki_secret_backend_role.nomad
  ]
  backend = var.vault_int_ca_path

  name        = vault_pki_secret_backend_role.nomad.name
  common_name = "server.global.nomad"
  alt_names   = ["localhost"]
  ttl         = "24h"
  ip_sans     = ["127.0.0.1"]
}

resource "vault_pki_secret_backend_cert" "nomad_client" {
  count = length(local.nomad_clients)

  depends_on = [
    vault_pki_secret_backend_role.nomad
  ]
  backend = var.vault_int_ca_path

  name        = vault_pki_secret_backend_role.nomad.name
  common_name = "client.global.nomad"
  alt_names   = ["localhost"]
  ttl         = "24h"
  ip_sans     = ["127.0.0.1"]
}

data "local_file" "nomad_tls_config" {
  filename = "${path.module}/files/tls.hcl"
}

resource "null_resource" "nomad_tls_server_config" {
  count = length(local.nomad_servers)
  triggers = {
    certificate  = vault_pki_secret_backend_cert.nomad_server[count.index].certificate
    private_key  = vault_pki_secret_backend_cert.nomad_server[count.index].private_key
    ca_cert      = vault_pki_secret_backend_cert.nomad_server[count.index].issuing_ca
    file_content = data.local_file.nomad_tls_config.content
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = local.nomad_servers[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = data.local_file.nomad_tls_config.content
    destination = "~/tls.hcl"
  }
  provisioner "file" {
    content     = vault_pki_secret_backend_cert.nomad_server[count.index].issuing_ca
    destination = "~/ca.crt"
  }
  provisioner "file" {
    content     = vault_pki_secret_backend_cert.nomad_server[count.index].certificate
    destination = "~/agent.crt"
  }
  provisioner "file" {
    content     = vault_pki_secret_backend_cert.nomad_server[count.index].private_key
    destination = "~/agent.key"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /opt/nomad/agent-certs/",
      "sudo mkdir -p /opt/nomad/agent-certs/",
      "sudo mv ~/*.crt /opt/nomad/agent-certs/",
      "sudo mv ~/*.key /opt/nomad/agent-certs/",
      "sudo mv ~/tls.hcl /etc/nomad.d/",
      "sudo systemctl restart nomad"
    ]
  }
}

resource "null_resource" "nomad_tls_client_config" {
  count = length(local.nomad_clients)
  triggers = {
    certificate  = vault_pki_secret_backend_cert.nomad_client[count.index].certificate
    private_key  = vault_pki_secret_backend_cert.nomad_client[count.index].private_key
    ca_cert      = vault_pki_secret_backend_cert.nomad_client[count.index].issuing_ca
    file_content = data.local_file.nomad_tls_config.content
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = local.nomad_clients[count.index]
    private_key = file("~/.ssh/id_rsa")
    certificate = file("~/.ssh/id_rsa-cert.pub")
  }
  provisioner "file" {
    content     = data.local_file.nomad_tls_config.content
    destination = "~/tls.hcl"
  }
  provisioner "file" {
    content     = vault_pki_secret_backend_cert.nomad_client[count.index].issuing_ca
    destination = "~/ca.crt"
  }
  provisioner "file" {
    content     = vault_pki_secret_backend_cert.nomad_client[count.index].certificate
    destination = "~/agent.crt"
  }
  provisioner "file" {
    content     = vault_pki_secret_backend_cert.nomad_client[count.index].private_key
    destination = "~/agent.key"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /opt/nomad/agent-certs/",
      "sudo mkdir -p /opt/nomad/agent-certs/",
      "sudo mv ~/*.crt /opt/nomad/agent-certs/",
      "sudo mv ~/*.key /opt/nomad/agent-certs/",
      "sudo mv ~/tls.hcl /etc/nomad.d/",
      "sudo systemctl restart nomad"
    ]
  }
}
