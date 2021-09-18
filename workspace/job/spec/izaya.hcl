job "izaya" {
  datacenters = ["roger"]
  type        = "service"

  group "grafana" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2d"
    }

    network {
      mode = "bridge"
      port "http" {
        to = 3000
      }
    }

    volume "host" {
      type      = "host"
      source    = "host"
      read_only = false
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    service {
      name = "izaya"
      tags = ["traefik.enable=true"]
      port = "http"
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana"
        ports = ["http"]
        volumes = [
          "/opt/nomad/volume/izaya/data:/var/lib/grafana"
        ]
      }

      resources {
        cpu    = 50
        memory = 100
      }
    }

    task "create-dir" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = ["local/create_dir.sh"]
      }

      volume_mount {
        volume = "host"
        destination = "/mnt/host"
        read_only = false
      }

      template {
        data = <<EOH
sudo mkdir -p /mnt/host/izaya/data
sudo chmod -R 777 /mnt/host/izaya/data
EOH
        destination = "local/create_dir.sh"
        change_mode = "noop"
      }

      lifecycle {
        hook = "prestart"
      }
    }
  }
}
