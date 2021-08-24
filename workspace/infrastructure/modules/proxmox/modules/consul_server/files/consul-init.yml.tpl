users:
  - name: consul
    system: true
write_files:
  - path: /etc/consul.d/00.consul.hcl
    content: |
      ${consul_config}
  - path: /etc/systemd/system/consul.service
    content: |
      [Unit]
      Description="HashiCorp Consul - A service mesh solution"
      Documentation=https://www.consul.io/
      Requires=network-online.target
      After=network-online.target
      ConditionFileNotEmpty=/etc/consul.d/00.consul.hcl

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
  - path: /etc/consul_template.d/00.consul.hcl
    content: |
      consul {
        address = "127.0.0.1:8500"
      }
  - path: /etc/systemd/system/consul_template.service
    content: |
      [Unit]
      Description="HashiCorp Consul Template"
      Documentation=https://www.consul.io/
      Requires=network-online.target
      After=network-online.target
      Wants=consul.service
      After=consul.service
      ConditionFileNotEmpty=/etc/consul_template.d/00.consul.hcl

      [Service]
      ExecStart=/usr/local/bin/consul-template -config=/etc/consul_template.d/
      ExecReload=/bin/kill -HUP $MAINPID
      ExecStop=/bin/kill -INT $MAINPID
      KillSignal=SIGINT
      KillMode=process
      Restart=on-failure
      RestartSec=42s

      [Install]
      WantedBy=multi-user.target
runcmd:
  - sudo cp /mnt/cifs/cloud-init/consul/${consul_version}/consul /usr/local/bin/
  - sudo cp /mnt/cifs/cloud-init/consul_template/${consul_template_version}/consul-template /usr/local/bin/
  - cd /usr/local/bin/
  - sudo chown consul:consul consul
  - sudo chown consul:consul consul-template
  - sudo chmod +x consul
  - sudo chmod +x consul-template
  - sudo mkdir -p /opt/consul/data
  - sudo chown -R consul:consul /opt/consul/data
  - sudo chmod -R 775 /opt/consul/data
  - sudo systemctl enable consul
  - sudo systemctl start consul
  - sudo systemctl enable consul_template
  - sudo systemctl start consul_template
