connect {
  ca_provider = "vault"
  ca_config {
    address = "https://10.10.30.120:8200"
    token = "${vault_token}"
    root_pki_path = "connect_root"
    intermediate_pki_path = "connect_inter"
  }
}
