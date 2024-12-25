locals {
  service_account_name          = var.service_account_id == null ? var.service_account_name : null
  node_groups_default_locations = coalesce(var.node_groups_default_locations, var.master_locations)

  # Generating node groups locations list for auto_scale policy
  chunked_node_groups_keys = var.node_groups != null ? chunklist(tolist(keys(var.node_groups)), length(var.master_locations)) : []
  auto_node_groups_locations = length(local.chunked_node_groups_keys) > 0 ? concat([
    for x, list in local.chunked_node_groups_keys : concat([
      for y, name in list : {
        node_group_name = name
        zone            = var.master_locations[y]["zone"]
        subnet_id       = var.master_locations[y]["subnet_id"]
      }
    ])
  ]...) : []
  master_locations_subnets_ids = concat(flatten([for location in var.master_locations : location.subnet_id]))

}

resource "yandex_iam_service_account" "service_account" {
  count = local.service_account_name == null ? 0 : 1

  name      = var.service_account_name
  folder_id = var.folder_id
}

locals {
  service_account_id             = try(yandex_iam_service_account.service_account[0].id, var.service_account_id)
  cilium_network_policy_provider = var.network_policy_provider == "CILIUM" ? true : false
}

resource "yandex_resourcemanager_folder_iam_member" "service_account" {
  count = local.service_account_name == null ? 0 : 1

  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${local.service_account_id}"
}

locals {
  node_service_account_name   = var.node_service_account_id == null ? var.node_service_account_name : null
  node_service_account_exists = local.node_service_account_name == null || var.service_account_name == var.node_service_account_name
}

resource "yandex_iam_service_account" "node_service_account" {
  count = local.node_service_account_exists ? 0 : 1

  name      = local.node_service_account_name
  folder_id = var.folder_id
}

locals {
  node_service_account_id = try(yandex_iam_service_account.node_service_account[0].id, local.node_service_account_exists ? coalesce(var.node_service_account_id, local.service_account_id) : null)
}

resource "yandex_resourcemanager_folder_iam_member" "node_service_account" {
  count = (local.node_service_account_name == null) || (var.service_account_name == var.node_service_account_name) ? 0 : 1

  folder_id = var.folder_id

  role   = "container-registry.images.puller"
  member = "serviceAccount:${local.node_service_account_id}"
}

resource "yandex_kubernetes_cluster" "cluster" {
  name                    = var.name
  description             = var.description
  folder_id               = var.folder_id
  network_id              = var.network_id
  cluster_ipv4_range      = var.cluster_ipv4_range
  service_ipv4_range      = var.service_ipv4_range
  service_account_id      = local.service_account_id
  node_service_account_id = local.node_service_account_id
  release_channel         = var.release_channel
  network_policy_provider = local.cilium_network_policy_provider ? null : var.network_policy_provider

  labels = var.labels

  master {
    version   = var.master_version
    public_ip = var.public_access

    dynamic "master_location" {
      for_each = var.master_locations

      content {
        zone      = master_location.value["zone"]
        subnet_id = master_location.value["subnet_id"]
      }
    }

    maintenance_policy {
      auto_upgrade = var.master_auto_upgrade

      dynamic "maintenance_window" {
        for_each = var.master_maintenance_windows

        content {
          day        = lookup(maintenance_window.value, "day", null)
          start_time = maintenance_window.value["start_time"]
          duration   = maintenance_window.value["duration"]
        }
      }
    }
  }

  // processing of this block depends from "network_policy_provider" variable
  dynamic "network_implementation" {
    for_each = local.cilium_network_policy_provider ? ["cilium"] : []
    content {
      cilium {}
    }
  }

  dynamic "kms_provider" {
    for_each = var.kms_provider_key_id == null ? [] : [var.kms_provider_key_id]

    content {
      key_id = kms_provider.value
    }
  }

  // to keep permissions of service account on destroy
  // until cluster will be destroyed
  depends_on = [yandex_resourcemanager_folder_iam_member.service_account]
}

resource "yandex_kubernetes_node_group" "node_groups" {
  for_each = var.node_groups

  cluster_id  = yandex_kubernetes_cluster.cluster.id
  name        = each.key
  description = lookup(each.value, "description", null)
  labels      = lookup(each.value, "labels", null)
  version     = lookup(each.value, "version", var.worker_version)

  node_labels            = try(each.value.node_labels, null)
  node_taints            = try(each.value.node_taints, null)
  allowed_unsafe_sysctls = try(each.value.allowed_unsafe_sysctls, null)

  instance_template {
    platform_id = lookup(each.value, "platform_id", null)
    nat         = lookup(each.value, "nat", null)
    metadata = {
      ssh-keys = fileexists("./pub_keys.txt") ? "${file("./pub_keys.txt")}" : null
    }

    resources {
      cores         = lookup(each.value, "cores", 2)
      core_fraction = lookup(each.value, "core_fraction", 100)
      memory        = lookup(each.value, "memory", 2)
    }

    boot_disk {
      type = lookup(each.value, "boot_disk_type", "network-hdd")
      size = lookup(each.value, "boot_disk_size", 64)
    }

    scheduling_policy {
      preemptible = lookup(each.value, "preemptible", false)
    }

    network_interface {
      subnet_ids = can(each.value["node_locations"]) ? flatten([
        for location in each.value["node_locations"] : location.subnet_id]
        ) : can(each.value["auto_scale"]) ? flatten([
          for location in local.auto_node_groups_locations : [location.subnet_id] if location.node_group_name == each.key
      ]) : local.master_locations_subnets_ids
      nat                = lookup(each.value, "nat", null)
      security_group_ids = lookup(each.value, "security_group_ids", null)
    }
  }

  scale_policy {
    dynamic "fixed_scale" {
      for_each = flatten([lookup(each.value, "fixed_scale", can(each.value["auto_scale"]) ? [] : [{ size = 1 }])])

      content {
        size = fixed_scale.value.size
      }
    }

    dynamic "auto_scale" {
      for_each = flatten([lookup(each.value, "auto_scale", [])])

      content {
        min     = auto_scale.value.min
        max     = auto_scale.value.max
        initial = auto_scale.value.initial
      }
    }
  }

  allocation_policy {
    dynamic "location" {
      for_each = can(each.value["node_locations"]) ? each.value["node_locations"] : can(each.value["auto_scale"]) ? [
        for location in local.auto_node_groups_locations : {
          zone      = location.zone
          subnet_id = location.subnet_id
        }
        if location.node_group_name == each.key
      ] : var.master_locations

      content {
        zone = location.value.zone
      }
    }
  }

  maintenance_policy {
    auto_repair  = lookup(each.value, "auto_repair", true)
    auto_upgrade = lookup(each.value, "auto_upgrade", true)

    dynamic "maintenance_window" {
      for_each = lookup(each.value, "maintenance_windows", [])

      content {
        day        = lookup(maintenance_window.value, "day", null)
        start_time = maintenance_window.value["start_time"]
        duration   = maintenance_window.value["duration"]
      }
    }
  }

  dynamic "deploy_policy" {
    for_each = anytrue([can(each.value["max_expansion"]), can(each.value["max_unavailable"])]) ? [{
      max_expansion   = each.value.max_expansion
      max_unavailable = each.value.max_unavailable
    }] : []

    content {
      max_expansion   = each.value.max_expansion
      max_unavailable = each.value.max_unavailable
    }
  }
}
