data "consul_service" "nomad_server" {
  name       = "nomad"
  datacenter = "rayleigh"
}

data "consul_service" "nomad_client" {
  name       = "nomad-client"
  datacenter = "rayleigh"
}

locals {
  nomad_servers = distinct(data.consul_service.nomad_server.service.*.node_address)
  nomad_clients = distinct(data.consul_service.nomad_client.service.*.node_address)
}
