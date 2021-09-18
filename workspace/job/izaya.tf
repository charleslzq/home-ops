resource "nomad_job" "izaya" {
  jobspec          = file("${path.module}/spec/izaya.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}

resource "nomad_job" "vector" {
  jobspec          = file("${path.module}/spec/vector.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
