vault {
  address = "http://openbao:8200"
}

auto_auth {
  method "approle" {
    mount_path = "auth/app"

    config = {
      role_id_file_path   = "/run/secrets/role_id"
      secret_id_file_path = "/run/secrets/secret_id"
    }
  }

  sink "file" {
    config = {
      path = "/run/openbao/token"
      mode = 0644
    }
  }
}
