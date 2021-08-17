datacenter = "rayleigh"
data_dir = "/opt/consul/data"
encrypt = ${encrypt_key}
ca_file = "/etc/consul.d/consul-agent-ca.pem"
cert_file = "/etc/consul.d/dc1-server-consul-0.pem"
key_file = "/etc/consul.d/dc1-server-consul-0-key.pem"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
retry_join = ${server_ip_list}
performance {
  raft_multiplier = 1
}
connect {
  enabled = true
}
server = true
bootstrap_expect = ${server_count}
ui = true
client_addr = "0.0.0.0"
advertise_addr = ${ip}
auto_encrypt {
  allow_tls = true
}
