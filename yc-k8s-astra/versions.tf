terraform {
  required_version = ">= 1.3.5"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.103.0"
    }
  }
}
