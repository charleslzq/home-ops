resource "nomad_job" "backup" {
  jobspec          = file("${path.module}/spec/backup.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
