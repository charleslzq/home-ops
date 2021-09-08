resource "nomad_job" "haruka" {
  jobspec          = file("${path.module}/spec/haruka.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
