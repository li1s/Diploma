output "external_v4_endpoint" {
  description = "An IPv4 external network address that is assigned to the master."

  value = yandex_kubernetes_cluster.cluster.master[0].external_v4_endpoint
}

output "internal_v4_endpoint" {
  description = "An IPv4 internal network address that is assigned to the master."

  value = yandex_kubernetes_cluster.cluster.master[0].internal_v4_endpoint
}

output "cluster_ca_certificate" {
  description = <<-EOF
  PEM-encoded public certificate that is the root of trust for
  the Kubernetes cluster.
  EOF

  value = yandex_kubernetes_cluster.cluster.master[0].cluster_ca_certificate
}

output "cluster_id" {
  description = "ID of a new Kubernetes cluster."

  value = yandex_kubernetes_cluster.cluster.id
}

output "node_groups" {
  description = "Attributes of yandex_node_group resources created in cluster"

  value = yandex_kubernetes_node_group.node_groups
}

output "service_account_id" {
  description = <<-EOF
  ID of service account used for provisioning Compute Cloud and VPC resources
  for Kubernetes cluster
  EOF

  value = local.service_account_id
}

output "node_service_account_id" {
  description = <<-EOF
  ID of service account to be used by the worker nodes of the Kubernetes cluster
  to access Container Registry or to push node logs and metrics
  EOF

  value = local.node_service_account_id
}
output "internal_cluster_cmd" {
  description = <<EOF
    Kubernetes cluster private IP address.
    Use the following command to download kube config and start working with Yandex Managed Kubernetes cluster:
    `$ yc managed-kubernetes cluster get-credentials --id <cluster_id> --internal`
    Note: Kubernetes internal cluster nodes are available from the virtual machines in the same VPC as cluster nodes.
  EOF
  value       = var.public_access == false ? "yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.cluster.id} --internal" : null
}

output "external_cluster_cmd" {
  description = <<EOF
    Kubernetes cluster public IP address.
    Use the following command to download kube config and start working with Yandex Managed Kubernetes cluster:
    `$ yc managed-kubernetes cluster get-credentials --id <cluster_id> --external`
    This command will automatically add kube config for your user; after that, you will be able to test it with the
    `kubectl get cluster-info` command.
  EOF
  value       = var.public_access ? "yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.cluster.id} --external" : null
}
