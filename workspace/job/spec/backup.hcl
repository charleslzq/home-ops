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

  // manually install postgres-client on related machines
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
        name = "odysseus"
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

  group "mashu" {
    volume "cifs" {
      type      = "host"
      source    = "cifs"
      read_only = false
    }

    volume "host" {
      type      = "host"
      source    = "host"
      read_only = true
    }

    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2c"
    }

    network {
      mode = "bridge"
    }

    service {
      name = "backup-mashu-db"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-mashu"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "backup-mashu-db" {
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
        PGUSER = "mashu"
        name = "mashu"
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
PGPASSWORD="{{with secret "database/data/mashu"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }
    }

    task "backup-mashu-data" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = ["local/backup_directory.sh"]
      }

      volume_mount {
        volume      = "cifs"
        destination = "/mnt/cifs"
        read_only   = false
      }

      volume_mount {
        volume      = "host"
        destination = "/mnt/host"
        read_only   = true
      }

      env {
        name = "mashu"
        dir = "/mnt/host/mashu"
      }

      template {
        data = <<EOH
${backup_directory_script}
EOH
        destination   = "local/backup_directory.sh"
        change_mode   = "noop"
      }
    }
  }

  group "bulma" {
    volume "cifs" {
      type      = "host"
      source    = "cifs"
      read_only = false
    }

    volume "host" {
      type      = "host"
      source    = "host"
      read_only = true
    }

    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2d"
    }

    task "backup-wallabag-db" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = ["local/backup_sqlite.sh"]
      }

      volume_mount {
        volume      = "cifs"
        destination = "/mnt/cifs"
        read_only   = false
      }

      volume_mount {
        volume      = "host"
        destination = "/mnt/host"
        read_only   = true
      }

      env {
        name = "bulma"
        database = "/mnt/host/bulma/data/db/wallabag.sqlite"
      }

      template {
        data = <<EOH
${backup_sqlite_script}
EOH
        destination   = "local/backup_sqlite.sh"
        change_mode   = "noop"
      }
    }
  }

  group "shanks" {
    volume "cifs" {
      type = "host"
      source = "cifs"
      read_only = false
    }

    volume "host" {
      type = "host"
      source = "host"
      read_only = true
    }

    constraint {
      attribute = "$${attr.unique.hostname}"
      value = "shanks"
    }

    network {
      mode = "bridge"
    }

    service {
      name = "backup-shanks-db"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-shanks"
              local_bind_port = 5432
            }
          }
        }
      }
    }

    task "backup-shanks-db" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = [
          "local/backup_postgres.sh"]
      }

      volume_mount {
        volume = "cifs"
        destination = "/mnt/cifs"
        read_only = false
      }

      env {
        PGHOST = "127.0.0.1"
        PGPORT = 5432
        PGUSER = "shanks"
        name = "shanks"
      }

      template {
        data = <<EOH
${backup_postgres_script}
EOH
        destination = "local/backup_postgres.sh"
        change_mode = "noop"
      }

      template {
        data = <<EOH
PGPASSWORD="{{with secret "database/data/shanks"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env = true
      }
    }

    task "backup-shanks-data" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = [
          "local/backup_directory.sh"]
      }

      volume_mount {
        volume = "cifs"
        destination = "/mnt/cifs"
        read_only = false
      }

      volume_mount {
        volume = "host"
        destination = "/mnt/host"
        read_only = true
      }

      env {
        name = "shanks"
        dir = "/mnt/host/shanks/data"
      }

      template {
        data = <<EOH
${backup_directory_script}
EOH
        destination = "local/backup_directory.sh"
        change_mode = "noop"
      }
    }
  }

  group "shouko" {
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
      name = "backup-shouko-db"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-shouko"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "backup-shouko-db" {
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
        PGUSER = "shouko"
        name = "shouko"
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
PGPASSWORD="{{with secret "database/data/shouko"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }
    }
  }
}
