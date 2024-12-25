# Example kubernetes module

This configuration creates Managed kubernetes cluster in YandexCloud with different sets of arguments.

## Usage

### Variable description

| Variable                          | Description                                                        |
|-----------------------------------|--------------------------------------------------------------------|
| `cloud_id`                        | Yandex Cloud ID                                                    |
| `folder_id`                       | Yandex Cloud Folder ID                                             |
| `network_id`                      | Yandex Cloud Network ID                                            |
| `service_account_key_file`        | Path to Yandex Cloud Service account json file                     |
| `name`                            | Cluster name                                                       |
| `kubernetes_version`              | Cluster kubernetes version                                         |
| `description`                     | Cluster description                                                |

Prepare your environment to work with Yandex Cloud

- Ensure you have set of ssh keys (public/private)
- Ensure you have a Yandex Cloud service account JSON key file
- Fill following variables in `terraform.tfvars`:
  * `cloud_id`
  * `folder_id`
  * `network_id`
  * `folder_id_interconnect`
- Fill pub_keys.txt
  * `username:<ssh public key>`
- Fill s3 `secret_key` and `access_key` in `backend.tf`

### Notice:
`You can source the module directly from a repository instead of using a local path. In this case, please refer to the Terraform documentation for details: https://registry.terraform.io/providers/hashicorp/github/latest/docs#accessing-modules-in-other-repositories`

## Create managed kubernetes cluster

```bash
$ terraform init
$ terraform plan
$ terraform apply
```
