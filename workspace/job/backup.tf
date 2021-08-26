resource "nomad_job" "backup-daily" {
  jobspec = templatefile("${path.module}/spec/backup.hcl.tpl", {
    backup_script = file("${path.module}/script/backup_consul.sh")
  })
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}