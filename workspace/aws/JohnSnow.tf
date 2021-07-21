provider aws {
  region = "ap-northeast-1"
}

provider vault {
  address = "http://127.0.0.1:8200"
  skip_tls_verify = true
}
