variable "rg_name" {
  type        = string
  description = "Resource group"

  validation {
    # https://github.com/toddkitta/azure-content/blob/master/articles/guidance/guidance-naming-conventions.md
    condition     = length(var.rg_name) > 3 && length(var.rg_name) < 64 && can(regex("[a-z,0-9,-,_]", var.rg_name))
    error_message = "The rg_name must consist of lowercase letters, numbers underscores, and hyphens only."
  }
}

variable "trial_name" {
  type        = string
  description = "Trial name. Use only lowercase letters and numbers"
}

variable "location" {
  type        = string
  description = "Azure region where to create resources."
  default     = "eastus2"
}

variable "environment" {
  type        = string
  description = "Environment name, e.g. 'dev' or 'stage'"
  default     = "dev"
}

variable "resource_id" {
  type        = string
  description = "The resource id that is connected to the private link."
}

variable "subnet_id" {
  type        = string
  description = "The subnet id."
}

variable "subresource_name" {
  type = string
  # https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
  description = "The subresource to protect (kv/sql/webapp)"
}

variable "application" {
  type        = string
  description = "The application this endpoints relates to (workload)."
}

variable "dns_zone_id" {
  type        = string
  description = "The id of the given dns zone."
}