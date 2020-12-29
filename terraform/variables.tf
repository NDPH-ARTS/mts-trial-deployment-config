variable "trial_name" {
  type        = string
  description = "Application name. Use only lowercase letters and numbers"
  default     = "starterterraform"
}

variable "environment" {
  type        = string
  description = "Environment name, e.g. 'dev' or 'stage'"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region where to create resources."
  default     = "UK south"
}

variable "site_image_name" {
  type        = string
  description = "site image name (fqdn)."
}

variable "site_image_tag" {
  type        = string
  description = "site image tag."
  default     = "latest"
}

variable "practitioner_image_name" {
  type        = string
  description = "practitioner image name (fqdn)."
}

variable "practitioner_image_tag" {
  type        = string
  description = "practitioner image tag."
  default     = "latest"
}

variable "config_server_image_name" {
  type        = string
  description = "configuration server image name (fqdn)."
}

variable "config_server_image_tag" {
  type        = string
  description = "configuration server image tag."
  default     = "latest"
}