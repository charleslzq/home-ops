resource "nomad_job" "violet" {
  jobspec          = file("${path.module}/spec/violet.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
