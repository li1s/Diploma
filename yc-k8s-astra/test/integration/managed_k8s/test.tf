terraform {
  required_version = ">= 1.3.5"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.96.1"
    }
  }
}

provider "yandex" {
  service_account_key_file = pathexpand(var.service_account_key_file)
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}

data "yandex_vpc_network" "interconnect" {
  name      = "interconnect-net"
  folder_id = var.folder_id_interconnect
}

data "yandex_vpc_subnet" "subnet-interconnect-a" {
  name      = "subnet-interconnect-a2"
  folder_id = var.folder_id_interconnect
}

locals {
  service_account_key_file = jsondecode(file(var.service_account_key_file))
  service_account_id       = local.service_account_key_file.service_account_id
}

module "kubernetes" {
  source     = "../../../"
  name       = var.name
  folder_id  = var.folder_id
  network_id = data.yandex_vpc_network.interconnect.id
  master_locations = [
    {
      subnet_id = data.yandex_vpc_subnet.subnet-interconnect-a.id
      zone      = data.yandex_vpc_subnet.subnet-interconnect-a.zone
    }
  ]
  # https://cloud.yandex.com/en-ru/docs/managed-kubernetes/security/#sa-annotation
  service_account_id      = local.service_account_id
  node_service_account_id = local.service_account_id

  public_access           = false
  master_version          = var.kubernetes_version
  worker_version          = var.kubernetes_version
  cluster_ipv4_range      = "10.200.0.0/16"
  service_ipv4_range      = "10.201.0.0/16"
  network_policy_provider = var.network_policy_provider

  node_groups = {
    "${var.name}-group" = {
      cores         = 2
      core_fraction = 50
      memory        = 4
      auto_scale = {
        min     = 1
        max     = 2
        initial = 1
      }
      boot_disk_type = "network-ssd"
      boot_disk_size = 32
      node_labels = {
        "node-pool" : "${var.name}-group"
      }
    }
  }
}

output "cluster_id" {
  value = module.kubernetes.cluster_id
}

output "service_account_id" {
  value = module.kubernetes.service_account_id
}

output "cluster_ca_certificate" {
  value = module.kubernetes.cluster_ca_certificate
}

output "internal_v4_endpoint" {
  value = module.kubernetes.internal_v4_endpoint
}
