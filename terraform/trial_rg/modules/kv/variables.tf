variable "rg_name" {
  type        = string
  description = "Resource group"
}

variable "tenant_id" {
  type        = string
  description = "Tenant id"
}

variable "trial_name" {
  type        = string
  description = "Trial name. Use only lowercase letters and numbers"
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