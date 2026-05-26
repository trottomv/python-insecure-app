storage "file" {
  path = "/openbao/data"
}

listener "tcp" {
  address     = "[::]:8200"
  tls_disable = true  # Use TLS in production!
}

auth "approle" {
  enabled = true
}

secrets "kv" {
  path = "secret"
}

ui = true

disable_mlock = true
