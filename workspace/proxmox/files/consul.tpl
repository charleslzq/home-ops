#cloud-config
write_files:
  - path: /etc/consul/consul.hcl
    content: |
      ${consul_config}