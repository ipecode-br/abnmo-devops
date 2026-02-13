variable "project_name" {
  type        = string
  description = "The project name"
  default     = "abnmo-svm"
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
  default     = ["development"]
}

variable "database_environments" {
  type        = set(string)
  description = "Set of environments to deploy database instances for (development, homolog, production)"
  default     = ["development"]
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

variable "prod_db_name" {
  type        = string
  description = "Production database name"
  sensitive   = true
}

variable "prod_db_user" {
  type        = string
  description = "Production database user"
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

# Database admin user credentials (has full database privileges)
variable "db_admin_user" {
  type        = string
  description = "Database admin username with full privileges"
  sensitive   = true
}

variable "db_admin_password" {
  type        = string
  description = "Database admin password"
  sensitive   = true
}

variable "mysql_root_password" {
  type        = string
  description = "MySQL root password"
  sensitive   = true
}

# AWS variables and secrets from secrets.auto.tfvars
variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_ses_access_key_id" {
  type        = string
  description = "Access key for AWS SES"
  sensitive   = true
}

variable "aws_ses_secret_access_key" {
  type        = string
  description = "Secret access key for AWS SES"
  sensitive   = true
}
