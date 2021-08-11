users:
  - name: consul
    system: true
write_files:
  - path: /etc/consul.d/consul.hcl
    content: |
      ${consul_config}
  - path: /etc/consul.d/consul-agent-ca.pem
    content: |
      ${consul_ca}
  - path: /etc/consul.d/dc1-server-consul-0.pem
    content: |
      ${consul_cert}
  - path: /etc/consul.d/dc1-server-consul-0-key.pem
    content: |
      ${consul_key}
  - path: /etc/systemd/system/consul.service
    content: |
      [Unit]
      Description="HashiCorp Consul - A service mesh solution"
      Documentation=https://www.consul.io/
      Requires=network-online.target
      After=network-online.target
      ConditionFileNotEmpty=/etc/consul.d/consul.hcl

      [Service]
      Type=notify
      User=consul
      Group=consul
      ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
      ExecReload=/bin/kill --signal HUP $MAINPID
      KillMode=process
      KillSignal=SIGTERM
      Restart=on-failure
      LimitNOFILE=65536

      [Install]
      WantedBy=multi-user.target
runcmd:
  - sudo cp /mnt/cifs/cloud-init/consul/${consul_version}/consul /usr/local/bin
  - cd /usr/local/bin/
  - sudo chown consul:consul consul
  - sudo chmod +x consul
  - sudo mv consul /usr/local/bin/
  - sudo mkdir -p /var/lib/consul
  - sudo chown -R consul:consul /var/lib/consul
  - sudo chmod -R 775 /var/lib/consul
  - sudo systemctl enable consul
  - sudo systemctl start consul