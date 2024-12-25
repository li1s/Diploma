# Yandex Cloud managed kubernetes Terraform module

Project for deployment of Terraform Module Yandex Cloud managed kubernetes

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | >= 0.103.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [yandex_iam_service_account.node_service_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_iam_service_account.service_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/iam_service_account) | resource |
| [yandex_kubernetes_cluster.cluster](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) | resource |
| [yandex_kubernetes_node_group.node_groups](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group) | resource |
| [yandex_resourcemanager_folder_iam_member.node_service_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.service_account](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_ipv4_range"></a> [cluster\_ipv4\_range](#input\_cluster\_ipv4\_range) | CIDR block. IP range for allocating pod addresses. It should not overlap with<br>any subnet in the network the Kubernetes cluster located in. Static routes will<br>be set up for this CIDR blocks in node subnets. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | A description of the Kubernetes cluster. | `string` | `null` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | The ID of the folder that the Kubernetes cluster belongs to. | `string` | n/a | yes |
| <a name="input_kms_provider_key_id"></a> [kms\_provider\_key\_id](#input\_kms\_provider\_key\_id) | KMS key ID. | `any` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A set of key/value label pairs to assign to the Kubernetes cluster. | `map(string)` | `{}` | no |
| <a name="input_master_auto_upgrade"></a> [master\_auto\_upgrade](#input\_master\_auto\_upgrade) | Boolean flag that specifies if master can be upgraded automatically. | `bool` | `true` | no |
| <a name="input_master_locations"></a> [master\_locations](#input\_master\_locations) | List of locations where the cluster will be created. If the list contains only one location, a zonal cluster will be created; if there are three locations, this will create a regional cluster. <br><br> Note: The master locations list may only have ONE or THREE locations. | <pre>list(object({<br>    zone      = string<br>    subnet_id = string<br>  }))</pre> | n/a | yes |
| <a name="input_master_maintenance_windows"></a> [master\_maintenance\_windows](#input\_master\_maintenance\_windows) | List of structures that specifies maintenance windows,<br>  when auto update for master is allowed.<br><br>  Example:<pre>master_maintenance_windows = [<br>    {<br>      start_time = "23:00"<br>      duration   = "3h"<br>    }<br>  ]</pre> | `list(map(string))` | `[]` | no |
| <a name="input_public_access"></a> [master\_public\_ip](#input\_master\_public\_ip) | Boolean flag. When true, Kubernetes master will have visible ipv4 address. | `bool` | `true` | no |
| <a name="input_master_version"></a> [master\_version](#input\_master\_version) | Version of Kubernetes that will be used for master. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of a specific Kubernetes cluster. | `string` | `null` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | The ID of the cluster network. | `string` | n/a | yes |
| <a name="input_network_policy_provider"></a> [network\_policy\_provider](#input\_network\_policy\_provider) | Network policy provider for Kubernetes cluster. Possible values: CALICO, CILIUM. If null, the policy provider will not be installed.| `string` | `null` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | Parameters of Kubernetes node groups. | `map` | `{}` | no |
| <a name="input_node_groups_default_locations"></a> [node\_groups\_default\_locations](#input\_node\_groups\_default\_locations) | Default locations of Kubernetes node groups.<br><br>If ommited, master\_locations will be used. | <pre>list(object({<br>    subnet_id = string<br>    zone      = string<br>  }))</pre> | `null` | no |
| <a name="input_node_ipv4_cidr_mask_size"></a> [node\_ipv4\_cidr\_mask\_size](#input\_node\_ipv4\_cidr\_mask\_size) | Size of the masks that are assigned to each node in the cluster. Effectively<br>limits maximum number of pods for each node. | `number` | `null` | no |
| <a name="input_node_service_account_id"></a> [node\_service\_account\_id](#input\_node\_service\_account\_id) | ID of service account to be used by the worker nodes of the Kubernetes<br>cluster to access Container Registry or to push node logs and metrics.<br><br>If omitted or equal to `service_account_id`, service account will be used<br>as node service account. | `string` | `null` | no |
| <a name="input_node_service_account_name"></a> [node\_service\_account\_name](#input\_node\_service\_account\_name) | Name of service account to create to be used by the worker nodes of<br>the Kubernetes cluster to access Container Registry or to push node logs<br>and metrics.<br><br>If omitted or equal to `service_account_name`, service account<br>will be used as node service account.<br><br>`node_service_account_name` is ignored if `node_service_account_id` is set. | `string` | `null` | no |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | Cluster release channel. | `string` | `"STABLE"` | no |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | ID of existing service account to be used for provisioning Compute Cloud<br>and VPC resources for Kubernetes cluster. Selected service account should have<br>edit role on the folder where the Kubernetes cluster will be located and on the<br>folder where selected network resides. | `string` | `null` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Name of service account to create to be used for provisioning Compute Cloud<br>and VPC resources for Kubernetes cluster.<br><br>`service_account_name` is ignored if `service_account_id` is set. | `string` | `null` | no |
| <a name="input_service_ipv4_range"></a> [service\_ipv4\_range](#input\_service\_ipv4\_range) | CIDR block. IP range Kubernetes service Kubernetes cluster IP addresses<br>will be allocated from. It should not overlap with any subnet in the network<br>the Kubernetes cluster located in. | `string` | `null` | no |
| <a name="input_worker_version"></a> [worker\_version](#input\_worker\_version) | Version of Kubernetes that will be used for worker node. | `string` | `null` | no |

Add required ssh public keys into the file `./pub_keys.txt` to have an access to worker nodes of node groups. Format:

```
username:ssh-rsa AAAAB3NzaC***********lP1ww username
username2:ssh-rsa ONEMOREkey***********avEHw username2
```

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | PEM-encoded public certificate that is the root of trust for<br>the Kubernetes cluster. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of a new Kubernetes cluster. |
| <a name="output_external_v4_endpoint"></a> [external\_v4\_endpoint](#output\_external\_v4\_endpoint) | An IPv4 external network address that is assigned to the master. |
| <a name="output_internal_v4_endpoint"></a> [internal\_v4\_endpoint](#output\_internal\_v4\_endpoint) | An IPv4 internal network address that is assigned to the master. |
| <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups) | Attributes of yandex\_node\_group resources created in cluster |
| <a name="output_node_service_account_id"></a> [node\_service\_account\_id](#output\_node\_service\_account\_id) | ID of service account to be used by the worker nodes of the Kubernetes cluster<br>to access Container Registry or to push node logs and metrics |
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | ID of service account used for provisioning Compute Cloud and VPC resources<br>for Kubernetes cluster |
<!-- END_TF_DOCS -->
