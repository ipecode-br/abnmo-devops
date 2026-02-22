variable "project_name" {
  type        = string
  description = "The project name"
  default     = "abnmo-svm"
}

variable "environment" {
  type        = string
  description = "Environment (development, homolog, production)"
}

variable "lambda_handler" {
  type        = string
  description = "Lambda function handler"
  default     = "index.handler"
}

variable "lambda_runtime" {
  type        = string
  description = "Lambda runtime (e.g., nodejs18.x)"
  default     = "nodejs22.x"
}

variable "timeout" {
  type        = number
  description = "Lambda timeout in seconds"
  default     = 10
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for the Lambda function"
  default     = {}
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for VPC config"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for Lambda VPC config"
  default     = []
}

variable "authorization_type" {
  type        = string
  description = "Lambda URL authorization type"
  default     = "NONE"
}

variable "cors_allow_credentials" {
  type    = bool
  default = true
}

variable "cors_allow_headers" {
  type    = list(string)
  default = ["authorization", "content-length", "content-type"]
}

variable "cors_allow_methods" {
  type    = list(string)
  default = ["DELETE", "HEAD", "PATCH", "PUT", "GET", "POST"]
}

variable "cors_allow_origins" {
  type        = list(string)
  description = "Allowed origins for CORS"
}

variable "cors_expose_headers" {
  type    = list(string)
  default = ["set-cookie"]
}

variable "cors_max_age" {
  type    = number
  default = 3600
}

variable "custom_domain_name" {
  type        = string
  description = "Custom domain name for the API Gateway"
  default     = null
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate to use for the custom domain"
  default     = null
}

variable "github_oidc_provider_arn" {
  type        = string
  description = "ARN of the GitHub OIDC provider"
}
