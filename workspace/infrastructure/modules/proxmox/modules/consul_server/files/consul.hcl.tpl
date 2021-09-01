datacenter = "rayleigh"
data_dir = "/opt/consul/data"
retry_join = ${server_ip_list}
performance {
  raft_multiplier = 1
}
server = true
bootstrap_expect = ${server_count}
ui = true
client_addr = "0.0.0.0"
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
