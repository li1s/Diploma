output "external_ingress_address" {
  value = yandex_vpc_address.external_ingress.external_ipv4_address[0].address
}

output "internal_cluster_cmd" {
  value = module.kubernetes.internal_cluster_cmd
}
