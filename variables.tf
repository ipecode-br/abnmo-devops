variable "project_name" {
  type        = string
  description = "The project name"
  default     = "abnmo-svm"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "api_domain" {
  type        = string
  description = "Base domain for API endpoints (e.g., abnmo.ipecode.com.br)"
  default     = "abnmo.ipecode.com.br"
}

variable "db_domain" {
  type        = string
  description = "Base domain for database endpoints (e.g., abnmo.ipecode.com.br)"
  default     = "abnmo.ipecode.com.br"
}

variable "backend_environments" {
  type        = set(string)
  description = "Set of environments to deploy backend resources for (development, homolog, production)"
  default     = ["development", "homolog"]
}

variable "database_environments" {
  type        = set(string)
  description = "Set of environments to deploy database instances for (development, homolog, production)"
  default     = ["development", "homolog"]
}

variable "dns_validation_complete" {
  type        = bool
  description = "Set to true after you've added the DNS validation records to your domain. Phase 1: false (get DNS records), Phase 2: true (deploy everything)"
  default     = true
}

# Database passwords from secrets.auto.tfvars
variable "dev_db_password" {
  type        = string
  description = "Development database password"
  sensitive   = true
}

variable "homolog_db_password" {
  type        = string
  description = "Homolog database password"
  sensitive   = true
}

variable "prod_db_password" {
  type        = string
  description = "Production database password"
  sensitive   = true
}

# Cookie secrets from secrets.auto.tfvars
variable "dev_cookie_secret" {
  type        = string
  description = "Development cookie secret"
  sensitive   = true
}

variable "homolog_cookie_secret" {
  type        = string
  description = "Homolog cookie secret"
  sensitive   = true
}

variable "prod_cookie_secret" {
  type        = string
  description = "Production cookie secret"
  sensitive   = true
}

# JWT secrets from secrets.auto.tfvars
variable "dev_jwt_secret" {
  type        = string
  description = "Development JWT secret"
  sensitive   = true
}

variable "homolog_jwt_secret" {
  type        = string
  description = "Homolog JWT secret"
  sensitive   = true
}

variable "prod_jwt_secret" {
  type        = string
  description = "Production JWT secret"
  sensitive   = true
}

variable "mysql_root_password" {
  type        = string
  description = "MySQL root password"
  sensitive   = true
}

# Admin user credentials (has full database privileges)
variable "db_admin_user" {
  type        = string
  description = "Database admin username with full privileges"
  default     = "abnmo_admin"
}

variable "db_admin_password" {
  type        = string
  description = "Database admin password"
  sensitive   = true
}
