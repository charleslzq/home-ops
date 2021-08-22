#cloud-config
apt:
  sources:
    docker.list:
      source: deb [arch=amd64] https://download.docker.com/linux/ubuntu hirsute stable
      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg-agent
  - software-properties-common
  - docker-ce
  - docker-ce-cli
  - containerd.io
write_files:
  - path: /etc/nomad.d/nomad.hcl
    content: |
      datacenter = "roger"
      data_dir = "/opt/nomad/data"

      client {
        enabled = true
        meta = {
          node_type = "${node_type}"
        }
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
  - sudo chmod +x nomad
  - sudo mkdir -p /opt/nomad/data
  - sudo systemctl enable nomad
  - sudo systemctl start nomad
  - sudo systemctl start docker
  - sudo systemctl enable docker
  - sudo addgroup ubuntu docker
