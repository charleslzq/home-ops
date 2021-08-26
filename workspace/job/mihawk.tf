resource "nomad_job" "mihawk" {
  jobspec          = file("${path.module}/spec/mihawk.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}