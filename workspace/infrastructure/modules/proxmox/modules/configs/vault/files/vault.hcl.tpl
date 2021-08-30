listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "${ip}:8201"
  tls_cert_file    = "/opt/vault/cert.pem"
  tls_key_file     = "/opt/vault/key.pem"
}

storage "consul" {
  address      = "127.0.0.1:8500"
  path         = "vault/"
  service      = "yuki"
  service_tags = "traefik.enable=true,traefik.http.services.yuki.loadbalancer.server.scheme=https,traefik.http.services.yuki.loadbalancer.serversTransport=internal@file"
}

api_addr = "http://${ip}:8200"
cluster_addr = "https://${ip}:8201"
ui = "true"
