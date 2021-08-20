tls {
  http = false
  rpc  = true

  ca_file   = "/opt/nomad/agent-certs/ca.crt"
  cert_file = "/opt/nomad/agent-certs/agent.crt"
  key_file  = "/opt/nomad/agent-certs/agent.key"

  verify_server_hostname = true
  verify_https_client    = true
}
