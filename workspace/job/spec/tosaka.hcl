job "tosaka" {
  datacenters = ["roger"]
  type = "system"

  group "pihole" {
    constraint {
      attribute = "$${meta.node_type}"
      value     = "dns"
    }

    network {
      port "http" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "dns" {
        static = 53
      }
    }

    vault {
      policies = ["${policy}"]
    }

    //sudo sed -r -i.orig 's/#?DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf
    //sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'
    //sudo systemctl restart systemd-resolved
    task "server" {
      driver = "docker"

      service {
        name = "tosaka"
        port = "http"

        check {
          type = "tcp"
          port = "http"
          interval = "10s"
          timeout = "2s"
        }
      }

      config {
        image = "pihole/pihole:latest"
        network_mode = "host"
        volumes = [
          "local/dnsmasq.conf:/etc/dnsmasq.d/pihole.conf",
          "/opt/nomad/volume/tosaka/pihole:/etc/pihole",
          "/opt/nomad/volume/tosaka/dnsmasq:/etc/dnsmasq.d",
        ]
      }

      env {
        TZ="Asia/Shanghai"
        PIHOLE_DNS_="1.1.1.1;8.8.8.8"
      }

      template {
        data = <<EOH
WEBPASSWORD="{{with secret "home/data/default"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/server.env"
        env = true
      }

      template {
        data = <<EOH
address=/zenq.me/10.10.30.110
address=/.zenq.me/10.10.30.110
EOH
        destination = "local/dnsmasq.conf"
      }
    }
  }
}
