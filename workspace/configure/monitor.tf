resource "consul_acl_policy" "prometheus" {
  name  = "prometheus"
  rules = <<-RULE
service_prefix "" {
  policy = "read"
}

agent_prefix "" {
  policy="read"
}

node_prefix "" {
  policy = "read"
}
RULE
}

resource "consul_acl_token" "prometheus" {
  description = "prometheus token"
  policies    = [consul_acl_policy.prometheus.name]
  local       = true
}

data "consul_acl_token_secret_id" "prometheus" {
  accessor_id = consul_acl_token.prometheus.id
}

data "consul_nodes" "consul_servers" {
  query_options {
    datacenter = "rayleigh"
  }
}

resource "null_resource" "prometheus" {
  provisioner "local-exec" {
    environment = {
      PROMETHEUS_CONSUL_TOKEN = data.consul_acl_token_secret_id.prometheus.secret_id
      PROMETHEUS_CONSUL_IPS   = jsonencode([for node in data.consul_nodes.consul_servers.nodes : node.address if node.name != replace(node.name, "rayleigh", "")])
    }
    command = "ansible-playbook _monitor.yml"
  }
}
