job "franky" {
  datacenters = ["roger"]
  type = "service"

  group "node-red" {
    network {
      mode = "bridge"
      port "http" {
        to = 1880
      }
    }

    volume "host" {
      type      = "host"
      source    = "host"
      read_only = false
    }

    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2d"
    }

    service {
      name = "franky"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.franky.middlewares=yashin",
      ]
      port = "http"
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
sudo mkdir -p /mnt/host/franky/data
EOH
        destination = "local/create_dir.sh"
        change_mode = "noop"
      }

      lifecycle {
        hook = "prestart"
      }
    }

    task "node-red-server" {
      driver = "docker"
      user = "root"

      config {
        image = "nodered/node-red"
        ports = ["http"]
        volumes = [
          "/opt/nomad/volume/franky/data:/data"
        ]
      }

      resources {
        cpu = 500
        memory = 300
      }
    }
  }
}
