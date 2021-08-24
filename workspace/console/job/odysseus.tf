resource "nomad_job" "odysseus" {
  jobspec = file("${path.module}/spec/odysseus.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
