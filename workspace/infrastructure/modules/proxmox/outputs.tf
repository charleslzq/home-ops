output "vaults" {
  value = local.vaults
}

output "consul_servers" {
  value = local.consul_servers
}

output "nomad_servers" {
  value = local.nomad_servers
}

output "gateways" {
  value = local.joker_nodes
}

output "dns_servers" {
  value = local.masters
}

output "workers" {
  value = local.classes
}

output "nas" {
  value = [{
    ip   = "10.10.30.180"
    name = "shanks"
  }]
}

output "relays" {
  value = local.relays
}
