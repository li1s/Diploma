variable "cloud_id" {
  type        = string
  default     = ""
  description = "The ID of the cloud to apply any resources to."
  validation {
    condition     = length(var.cloud_id) == 20
    error_message = "Must be a 20 character string."
  }
}

variable "folder_id" {
  type        = string
  default     = "b1gct71s3m2h4jupiker"
  description = "The ID of the folder to apply anu resources to"
  validation {
    condition     = length(var.folder_id) == 20
    error_message = "Must be a 20 character string."
  }
}

variable "local_admin" {
  description = "node administrator name"
  type        = string
  default     = "astra"
}

variable "local_admin_public_key_path" {
  description = "node adminstrator public key"
  type        = string
  default     = "/root/.ssh/id_rsa.pub"
}

variable "service_account_key_file" {
  default     = "/root/yc_bot.json"
  description = "Service account auth key file"
}

variable "folder_id_interconnect" {
  description = "Interconnect Folder ID"
}

variable "name" {
  type    = string
  default = "ci-test"
  validation {
    condition     = length(var.name) <= 20
    error_message = "Must be a 20 or less character string."
  }
}

variable "kubernetes_version" {
  type    = string
  default = "1.28"
}

variable "description" {
  description = "A description of the Kubernetes cluster."
  type        = string
  default     = null
}

variable "network_policy_provider" {
  description = <<-EOF
  Network policy provider for Kubernetes cluster.
  Possible values: CALICO, CILIUM.
  If the value is null, the policy implementation provider will not be
  installed, and the network will be implemented by Kubenet.
  EOF
  type        = string
  default     = "CILIUM"
}
