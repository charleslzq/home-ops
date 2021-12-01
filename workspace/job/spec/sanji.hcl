job "sanji" {
  datacenters = ["roger"]
  type = "service"

  vault {
    policies = ["${policy}"]
  }

  group "mealie" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2c"
    }
    network {
      mode = "bridge"
      port "http" {
        to = 80
      }
    }
    volume "host" {
      type      = "host"
      source    = "host"
      read_only = false
    }

    service {
      name = "sanji"
      tags = ["traefik.enable=true"]
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-sanji"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "mealie" {
      driver = "docker"

      config {
        image = "hkotel/mealie:latest"
        ports = ["http"]
        volumes = [
          "/opt/nomad/volume/sanji/data:/app/data",
        ]
      }

      env {
        PUID = 1000
        PGID = 1000
        TZ = "Asia/Shanghai"
        DB_ENGINE = "postgres" # Optional: 'sqlite', 'postgres'
        POSTGRES_USER = "sanji"
        POSTGRES_SERVER = "localhost"
        POSTGRES_PORT = 5432
        POSTGRES_DB = "sanji"
        RECIPE_PUBLIC = true
        RECIPE_SHOW_NUTRITION = true
        RECIPE_SHOW_ASSETS = true
        RECIPE_LANDSCAPE_VIEW = true
        RECIPE_DISABLE_COMMENTS = false
        RECIPE_DISABLE_AMOUNT = false
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD={{with secret "database/data/sanji"}}{{.Data.data.password}}{{end}}
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu = 500
        memory = 300
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
sudo mkdir -p /mnt/host/sanji/data
sudo chmod -R 777 /mnt/host/sanji/data
EOH
        destination = "local/create_dir.sh"
        change_mode = "noop"
      }

      lifecycle {
        hook = "prestart"
      }
    }
  }

  group "mealie-db" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2c"
    }

    network {
      mode = "bridge"
      port "db" {
        to = 5432
      }
    }

    volume "host" {
      type      = "host"
      source    = "host"
      read_only = false
    }

    service {
      name = "db-sanji"
      port = "db"
      address_mode = "alloc"

      connect {
        sidecar_service {}
      }
    }

    task "db" {
      driver = "docker"

      config {
        image = "postgres:13"
        ports = ["db"]
        volumes = [
          "/opt/nomad/volume/sanji/db:/var/lib/postgresql/data",
        ]
      }

      env {
        POSTGRES_USER = "sanji"
        POSTGRES_DB = "sanji"
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/sanji"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu = 100
        memory = 200
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
sudo mkdir -p /mnt/host/sanji/db
sudo chmod -R 777 /mnt/host/sanji/db
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
