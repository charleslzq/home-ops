users:
  - name: nomad
    system: true
write_files:
  - path: /etc/nomad.d/nomad.hcl
    content: |
      datacenter = "roger"
      data_dir = "/opt/nomad/data"

      server {
        enabled          = true
        bootstrap_expect = 3
      }

      acl {
        enabled = true
      }
  - path: /etc/systemd/system/nomad.service
    content: |
      [Unit]
      Description=Nomad
      Documentation=https://www.nomadproject.io/docs/
      Wants=network-online.target
      After=network-online.target

      # When using Nomad with Consul it is not necessary to start Consul first. These
      # lines start Consul before Nomad as an optimization to avoid Nomad logging
      # that Consul is unavailable at startup.
      Wants=consul.service
      After=consul.service

      [Service]
      User=nomad
      Group=nomad
      ExecReload=/bin/kill -HUP $MAINPID
      ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d/
      KillMode=process
      KillSignal=SIGINT
      LimitNOFILE=65536
      LimitNPROC=infinity
      Restart=on-failure
      RestartSec=2

      ## Configure unit start rate limiting. Units which are started more than
      ## *burst* times within an *interval* time span are not permitted to start any
      ## more. Use `StartLimitIntervalSec` or `StartLimitInterval` (depending on
      ## systemd version) to configure the checking interval and `StartLimitBurst`
      ## to configure how many starts per interval are allowed. The values in the
      ## commented lines are defaults.

      # StartLimitBurst = 5

      ## StartLimitIntervalSec is used for systemd versions >= 230
      # StartLimitIntervalSec = 10s

      ## StartLimitInterval is used for systemd versions < 230
      # StartLimitInterval = 10s

      TasksMax=infinity
      OOMScoreAdjust=-1000

      [Install]
      WantedBy=multi-user.target
runcmd:
  - sudo cp /mnt/cifs/cloud-init/nomad/${nomad_version}/nomad /usr/local/bin/
  - cd /usr/local/bin/
  - sudo chown nomad:nomad nomad
  - sudo chmod +x nomad
  - sudo mkdir -p /opt/nomad/data
  - sudo chown -R nomad:nomad /opt/nomad/data
  - sudo chmod -R 775 /opt/nomad/data
  - sudo systemctl enable nomad
  - sudo systemctl start nomad
