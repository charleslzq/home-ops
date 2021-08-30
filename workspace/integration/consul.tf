module "consul_vault_integration" {
  depends_on = [
    vault_pki_secret_backend_intermediate_set_signed.intermediate,
    module.consul_template_vault_integration,
  ]

  source            = "./modules/consul_vault"
  vault_address     = local.vault_address
  vault_int_ca_path = vault_pki_secret_backend.pki_int.path
  consul_servers    = local.consul_servers
  consul_clients    = local.consul_clients
}

//resource "null_resource" "rm_tls_config" {
//  count = length(local.all_servers)
//
//  connection {
//    type        = "ssh"
//    user        = "ubuntu"
//    host        = local.all_servers[count.index]
//    private_key = file("~/.ssh/id_rsa")
//    certificate = file("~/.ssh/id_rsa-cert.pub")
//  }
//  provisioner "remote-exec" {
//    inline = [
//      "sudo rm -p /etc/consul.d/tls.hcl",
//      "sudo rm -p /etc/consul.d/20.tls.hcl",
//      "sudo systemctl restart consul",
//    ]
//  }
//}
