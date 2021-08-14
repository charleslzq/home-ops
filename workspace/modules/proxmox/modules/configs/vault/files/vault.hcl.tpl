listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "${ip}:8201"
  tls_disable      = "true"
}

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

api_addr = "http://${ip}:8200"
cluster_addr = "https://${ip}:8201"
