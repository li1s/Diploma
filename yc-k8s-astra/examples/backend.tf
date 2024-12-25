terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    region                      = "ru-central1"
    bucket                      = "service-k8s-states"
    key                         = "k8s-example"
    access_key                  = ""
    secret_key                  = ""
    skip_region_validation      = "true"
    skip_credentials_validation = "true"
  }
}
