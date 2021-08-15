datacenter = "rayleigh"
data_dir = "/opt/consul/data"
encrypt = ${encrypt_key}
ca_file = "/etc/consul.d/consul-agent-ca.pem"
cert_file = "/etc/consul.d/dc1-client-consul-0.pem"
key_file = "/etc/consul.d/dc1-client-consul-0-key.pem"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
retry_join = ${server_ip_list}
server = false
client_addr = "127.0.0.1"
advertise_addr = ${ip}
connect {
  enabled = true
}
