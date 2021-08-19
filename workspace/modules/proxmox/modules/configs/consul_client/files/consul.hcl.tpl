datacenter = "rayleigh"
data_dir = "/opt/consul/data"
retry_join = ${server_ip_list}
server = false
client_addr = "127.0.0.1"
advertise_addr = ${ip}
connect {
  enabled = true
}
