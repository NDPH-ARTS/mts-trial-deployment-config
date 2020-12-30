variable "rg_name" {
  type        = string
  description = "Resource group"
}

variable "trial_name" {
  type        = string
  description = "Trial name. Use only lowercase letters and numbers"
}

variable "location" {
  type        = string
  description = "Azure region where to create resources."
  default     = "UK south"
}

variable "app_service_plan_id" {
  type        = string
  description = "The app service plan id."
}

variable "fhir_image_name" {
  type        = string
  description = "Fhir image name (fqdn)."
  default     = "mcr.microsoft.com/healthcareapis/r4-fhir-server"
}

variable "fhir_image_tag" {
  type        = string
  description = "Fhir image tag."
  default     = "latest"
}

variable "fhirsqluser" {
  type        = string
  description = "Fhir sql server user."
  default     = "myfhiruser"
}