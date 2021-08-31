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

curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

