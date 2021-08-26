users:
  - name: vault
    system: true
write_files:
  - path: /etc/vault.d/vault.hcl
    content: |
      ${vault_config}
  - path: /opt/vault/cert.pem
    content: |
      ${vault_cert}
  - path: /opt/vault/key.pem
    content: |
      ${vault_key}
  - path: /usr/local/share/ca-certificates/extra/ca.crt
    content: |
      ${vault_ca}
  - path: /etc/systemd/system/vault.service
    content: |
      [Unit]
      Description=Vault secret management tool
      Requires=network-online.target
      After=network-online.target
      Wants=consul.service
      After=consul.service

      [Service]
      User=vault
      Group=vault
      PIDFile=/var/run/vault/vault.pid
      ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
      ExecReload=/bin/kill -HUP $MAINPID
      KillMode=process
      KillSignal=SIGTERM
      Restart=on-failure
      RestartSec=42s
      LimitMEMLOCK=infinity

      [Install]
      WantedBy=multi-user.target
runcmd:
  - sudo cp /mnt/cifs/cloud-init/vault/${vault_version}/vault /usr/local/bin/
  - cd /usr/local/bin/
  - sudo chown vault:vault vault
  - sudo chmod +x vault
  - sudo update-ca-certificates
  - sudo systemctl enable vault
  - sudo systemctl start vault
