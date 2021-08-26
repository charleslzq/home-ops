resource "nomad_job" "mashu" {
  jobspec          = file("${path.module}/spec/mashu.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
