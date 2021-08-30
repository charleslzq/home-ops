{{ with secret "pki_int/issue/consul-cluster" "common_name=client.rayleigh.consul" "ttl=24h"}}
{{ .Data.issuing_ca }}
{{ end }}
