write_files:
  - path: /etc/traefik/traefik.yml
    content: |
      ${traefik_config}
  - path: /etc/traefik.d/https.yml
    content: |
      tls:
        certificates:
          - certFile: /etc/traefik.d/https/fullchain.pem
            keyFile: /etc/traefik.d/https/privkey.pem
            stores:
              - default
        stores:
          default:
            defaultCertificate:
              certFile: /etc/traefik.d/https/fullchain.pem
              keyFile: /etc/traefik.d/https/privkey.pem

  - path: /etc/systemd/system/traefik.service
    content: |
      [Unit]
      Description="Traefik - Gateway"
      Documentation=https://www.consul.io/
      Requires=network-online.target
      After=network-online.target
      Wants=consul.service
      After=consul.service
      ConditionFileNotEmpty=/etc/traefik/traefik.yml

      [Service]
      Type=notify
      ExecStart=/usr/local/bin/traefik --configfile=/etc/traefik.d/traefik.yml
      ExecReload=/bin/kill --signal HUP $MAINPID
      KillMode=process
      KillSignal=SIGTERM
      Restart=on-failure
      LimitNOFILE=65536

      [Install]
      WantedBy=multi-user.target
  - path: /etc/consul.d/traefik.hcl
    content: |
      service {
        name = "joker"
        port = 8080
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.joker.tls=true"
        ]
      }
runcmd:
  - sudo cp /mnt/cifs/cloud-init/traefik/${traefik_version}/traefik /usr/local/bin/
  - sudo mkdir /etc/traefik.d/
  - sudo cp -r /mnt/cifs/certificates/https /etc/traefik.d/
  - cd /usr/local/bin/
  - sudo chmod +x traefik
  - sudo systemctl enable traefik
  - sudo systemctl start traefik
