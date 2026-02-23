variable "domain" {
  description = "Domínio para SES"
  type        = string
  default     = null
}

variable "manage_dns" {
  description = "Se true, cria registros no Route53"
  type        = bool
  default     = false
}

variable "zone_id" {
    description = "Route53 Zone ID (mandatory if manage_dns = true)"
  type    = string
  default = null

  validation {
    condition     = var.manage_dns == false || var.zone_id != null
    error_message = "zone_id is mandatory when manage_dns = true"
  }
}

variable "enable_dkim" {
  type    = bool
  default = true
}

variable "email_identities" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
