job "backup-daily" {
  datacenters = ["roger"]
  type        = "batch"
  periodic {
    cron             = "0 0 * * * *"
    prohibit_overlap = true
    time_zone = "Asia/Shanghai"
  }

  vault {
   policies = ["${policy}"]
  }

  group "consul" {
    volume "cifs" {
      type      = "host"
      source    = "cifs"
      read_only = false
    }

    constraint {
      attribute = "$${meta.node_type}"
      value     = "gateway"
    }

    task "consul_backup" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = ["local/backup_consul.sh"]
      }

      volume_mount {
        volume      = "cifs"
        destination = "/mnt/cifs"
        read_only   = false
      }

      template {
        data = <<EOH
CONSUL_HTTP_TOKEN="{{with secret "consul/creds/consul-server-role"}}{{.Data.token}}{{end}}"
EOH
        destination = "secrets/consul.env"
        env = true
      }

      template {
        data = <<EOH
${backup_consul_script}
EOH
        destination   = "local/backup_consul.sh"
        change_mode   = "noop"
      }

      logs {
        max_files     = 3
        max_file_size = 10
      }
    }
  }

  group "odysseus" {
    volume "cifs" {
      type      = "host"
      source    = "cifs"
      read_only = false
    }

    constraint {
      attribute = "$${meta.node_type}"
      value     = "dns"
    }

    network {
      mode = "bridge"
    }

    service {
      name = "backup-odysseus-db"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-odysseus"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "backup-odysseus-db" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = ["local/backup_postgres.sh"]
      }

      volume_mount {
        volume      = "cifs"
        destination = "/mnt/cifs"
        read_only   = false
      }

      env {
        PGHOST = "127.0.0.1"
        PGPORT = 5432
        PGUSER = "odysseus"
      }

      template {
        data = <<EOH
${backup_postgres_script}
EOH
        destination   = "local/backup_postgres.sh"
        change_mode   = "noop"
      }

      template {
        data = <<EOH
PGPASSWORD="{{with secret "database/data/odysseus"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }
    }
  }
}
