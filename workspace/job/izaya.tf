resource "nomad_job" "izaya" {
  jobspec          = file("${path.module}/spec/izaya.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}

resource "nomad_job" "fluent_bit" {
  jobspec          = file("${path.module}/spec/fluent_bit.hcl")
  purge_on_destroy = true

  hcl2 {
    enabled = true
  }
}
