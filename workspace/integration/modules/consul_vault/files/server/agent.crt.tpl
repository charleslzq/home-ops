{{ with secret "pki_int/issue/consul-cluster" "common_name=server.rayleigh.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1"}}
{{ .Data.certificate }}
{{ end }}
