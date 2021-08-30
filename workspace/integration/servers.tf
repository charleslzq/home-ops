locals {
  vault_address  = "https://10.10.30.120:8200"
  nomad_servers  = ["10.10.30.210", "10.10.30.211", "10.10.30.212"]
  nomad_clients  = [
    "10.10.30.50", "10.10.30.51", "10.10.30.52",
    "10.10.30.111", "10.10.30.112",
    "10.10.30.234", "10.10.30.236",
  ]
  vaults         = ["10.10.30.121", "10.10.30.122"]
  consul_servers = ["10.10.30.99", "10.10.30.100", "10.10.30.101"]
  consul_clients = concat(local.vaults, local.nomad_servers, local.nomad_clients)
  all_servers    = concat(local.consul_servers, local.consul_clients)
}
