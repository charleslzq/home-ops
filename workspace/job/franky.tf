resource "nomad_job" "franky" {
  jobspec          = file("${path.module}/spec/franky.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
