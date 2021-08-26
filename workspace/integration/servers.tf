data "consul_service" "nomad_server" {
  provider = consul.home

  name       = "nomad"
  datacenter = "rayleigh"
}

data "consul_service" "nomad_client" {
  provider = consul.home

  name       = "nomad-client"
  datacenter = "rayleigh"
}

data "consul_service" "vault" {
  provider = consul.home

  name       = "yuki"
  datacenter = "rayleigh"
}

data "consul_service" "consul" {
  provider = consul.home

  name       = "consul"
  datacenter = "rayleigh"
}

locals {
  vault_address  = "https://10.10.30.120:8200"
  nomad_servers  = distinct(data.consul_service.nomad_server.service.*.node_address)
  nomad_clients  = distinct(data.consul_service.nomad_client.service.*.node_address)
  vaults         = distinct(data.consul_service.vault.service.*.node_address)
  consul_servers = distinct(data.consul_service.consul.service.*.node_address)
  all_servers    = concat(local.consul_servers, local.vaults, local.nomad_servers, local.nomad_clients)
}
