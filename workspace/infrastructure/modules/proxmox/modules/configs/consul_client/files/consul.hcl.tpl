datacenter = "rayleigh"
data_dir = "/opt/consul/data"
retry_join = ${server_ip_list}
server = false
client_addr = "127.0.0.1"
advertise_addr = ${ip}

ports {
  grpc = 8502
}

connect {
  enabled = true
}

acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
