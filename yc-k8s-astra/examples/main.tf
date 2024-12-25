provider "yandex" {
  service_account_key_file = pathexpand(var.service_account_key_file)
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}

locals {
  # read json
  service_account_key_file = jsondecode(file(var.service_account_key_file))
  # get sa id
  service_account_id = local.service_account_key_file.service_account_id
}

module "kubernetes" {
  source = "git::ssh://git@git.astralinux.ru:7999/amft/yandex-cloud-k8s.git?ref=feature/RAIT-2028-amft-managed-k8s-yc"

  name = var.name

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
      cores           = 4
      core_fraction   = 100
      memory          = 16
      max_expansion   = 1
      max_unavailable = 1
      auto_scale = {
        min     = 1
        max     = 3
        initial = 1
      }
      boot_disk_type = "network-ssd"
      boot_disk_size = 64
      node_labels = {
        "node-pool" : "${var.name}-group"
      }
    }
  }
}

resource "yandex_vpc_address" "external_ingress" {
  name = "${var.name}-ingress-external"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "null_resource" "kubeconfig" {
  depends_on = [module.kubernetes]

  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    /usr/local/bin/yc config profile create sa-profile && \
    /usr/local/bin/yc config set service-account-key service-k8s-bot.json && \
    /usr/local/bin/${module.kubernetes.internal_cluster_cmd} --force
    EOT
  }
}
