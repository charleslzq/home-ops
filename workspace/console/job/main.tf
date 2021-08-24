resource "nomad_job" "backup" {
  jobspec = templatefile("${path.module}/spec/backup.hcl.tpl", {
    backup_script = file("${path.module}/script/backup_consul.sh")
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}

resource "nomad_job" "traefik" {
  jobspec = templatefile("${path.module}/spec/traefik.hcl.tpl", {
    traefik_version = "2.5.1"
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
