resource "nomad_job" "bulma" {
  jobspec          = file("${path.module}/spec/bulma.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
