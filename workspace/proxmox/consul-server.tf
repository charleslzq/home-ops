module "consul_server" {
  source         = "./consul_server"
  vm_name        = "consul-server-1"
  proxmox_node   = "skypiea"
  consul_version = "1.10.1"
  ip             = "10.10.30.99/24"
  gateway        = "10.10.30.1"
  ssh_ca_key     = data.vault_generic_secret.ssh_ca.data.public_key
  encrypt_key    = data.vault_generic_secret.consul_config.data.encrypt-key
  ca_cert        = vault_pki_secret_backend_cert.consul.issuing_ca
  cert           = vault_pki_secret_backend_cert.consul.certificate
  private_key    = vault_pki_secret_backend_cert.consul.private_key
}
