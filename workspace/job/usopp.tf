resource "nomad_job" "usopp" {
  jobspec          = file("${path.module}/spec/usopp.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
