# Backend Environment Outputs (conditional based on deployed environments)
output "backend_outputs" {
  description = "Outputs for all deployed backend environments"
  value = {
    for env in var.backend_environments : env => {
      lambda_function_name = module.abnmo_svm_backend[env].lambda_function_name
      lambda_function_url  = module.abnmo_svm_backend[env].lambda_function_url
      api_gateway_url      = module.abnmo_svm_backend[env].api_gateway_url
      custom_domain_name   = var.dns_validation_complete ? module.abnmo_svm_backend[env].custom_domain_name : "Phase 1: Add DNS records first, then set dns_validation_complete=true"
      custom_domain_target = var.dns_validation_complete ? module.abnmo_svm_backend[env].custom_domain_target : "Phase 1: Add DNS records first, then set dns_validation_complete=true"
    }
  }
}

# Individual environment outputs for backward compatibility
output "dev_lambda_function_name" {
  description = "Name of the development Lambda function"
  value       = contains(var.backend_environments, "development") ? module.abnmo_svm_backend["development"].lambda_function_name : "Development environment not deployed"
}

output "dev_lambda_function_url" {
  description = "URL of the development Lambda function"
  value       = contains(var.backend_environments, "development") ? module.abnmo_svm_backend["development"].lambda_function_url : "Development environment not deployed"
}

output "dev_api_gateway_url" {
  description = "URL of the development API Gateway"
  value       = contains(var.backend_environments, "development") ? module.abnmo_svm_backend["development"].api_gateway_url : "Development environment not deployed"
}

output "dev_custom_domain_name" {
  description = "Custom domain name for the development API"
  value       = contains(var.backend_environments, "development") ? (var.dns_validation_complete ? module.abnmo_svm_backend["development"].custom_domain_name : "Phase 1: Add DNS records first, then set dns_validation_complete=true") : "Development environment not deployed"
}

output "dev_custom_domain_target" {
  description = "Target domain for CNAME record (development)"
  value       = contains(var.backend_environments, "development") ? (var.dns_validation_complete ? module.abnmo_svm_backend["development"].custom_domain_target : "Phase 1: Add DNS records first, then set dns_validation_complete=true") : "Development environment not deployed"
}

# Homolog Environment Outputs
output "homolog_lambda_function_name" {
  description = "Name of the homolog Lambda function"
  value       = contains(var.backend_environments, "homolog") ? module.abnmo_svm_backend["homolog"].lambda_function_name : "Homolog environment not deployed"
}

output "homolog_lambda_function_url" {
  description = "URL of the homolog Lambda function"
  value       = contains(var.backend_environments, "homolog") ? module.abnmo_svm_backend["homolog"].lambda_function_url : "Homolog environment not deployed"
}

output "homolog_api_gateway_url" {
  description = "URL of the homolog API Gateway"
  value       = contains(var.backend_environments, "homolog") ? module.abnmo_svm_backend["homolog"].api_gateway_url : "Homolog environment not deployed"
}

output "homolog_custom_domain_name" {
  description = "Custom domain name for the homolog API"
  value       = contains(var.backend_environments, "homolog") ? (var.dns_validation_complete ? module.abnmo_svm_backend["homolog"].custom_domain_name : "Phase 1: Add DNS records first, then set dns_validation_complete=true") : "Homolog environment not deployed"
}

output "homolog_custom_domain_target" {
  description = "Target domain for CNAME record (homolog)"
  value       = contains(var.backend_environments, "homolog") ? (var.dns_validation_complete ? module.abnmo_svm_backend["homolog"].custom_domain_target : "Phase 1: Add DNS records first, then set dns_validation_complete=true") : "Homolog environment not deployed"
}

# Production Environment Outputs
output "prod_lambda_function_name" {
  description = "Name of the production Lambda function"
  value       = contains(var.backend_environments, "production") ? module.abnmo_svm_backend["production"].lambda_function_name : "Production environment not deployed"
}

output "prod_lambda_function_url" {
  description = "URL of the production Lambda function"
  value       = contains(var.backend_environments, "production") ? module.abnmo_svm_backend["production"].lambda_function_url : "Production environment not deployed"
}

output "prod_api_gateway_url" {
  description = "URL of the production API Gateway"
  value       = contains(var.backend_environments, "production") ? module.abnmo_svm_backend["production"].api_gateway_url : "Production environment not deployed"
}

output "prod_custom_domain_name" {
  description = "Custom domain name for the production API"
  value       = contains(var.backend_environments, "production") ? (var.dns_validation_complete ? module.abnmo_svm_backend["production"].custom_domain_name : "Phase 1: Add DNS records first, then set dns_validation_complete=true") : "Production environment not deployed"
}

output "prod_custom_domain_target" {
  description = "Target domain for CNAME record (production)"
  value       = contains(var.backend_environments, "production") ? (var.dns_validation_complete ? module.abnmo_svm_backend["production"].custom_domain_target : "Phase 1: Add DNS records first, then set dns_validation_complete=true") : "Production environment not deployed"
}

# Centralized Certificate Outputs
output "wildcard_certificate_arn" {
  description = "ARN of the wildcard certificate for all API domains"
  value       = aws_acm_certificate.wildcard_api.arn
}

output "wildcard_certificate_validation_records" {
  description = "DNS validation records for the wildcard certificate"
  value       = aws_acm_certificate.wildcard_api.domain_validation_options
}

# Formatted DNS validation records for easy copying
output "dns_validation_records_formatted" {
  description = "Formatted DNS validation records for manual DNS configuration"
  value = {
    for record in aws_acm_certificate.wildcard_api.domain_validation_options : record.domain_name => {
      name   = record.resource_record_name
      type   = record.resource_record_type
      value  = record.resource_record_value
      domain = record.domain_name
    }
  }
}

output "api_domain" {
  description = "Base API domain configured"
  value       = var.api_domain
}

output "db_domain" {
  description = "Base database domain configured"
  value       = var.db_domain
}

# Database domain outputs for manual DNS configuration
output "database_dns_records" {
  description = "DNS records you need to configure manually for database domains"
  value = {
    for env in var.database_environments : "db-${env}.${var.db_domain}" => {
      type   = "A"
      name   = "db-${env}"
      value  = aws_eip.database_eip[env].public_ip
      domain = var.db_domain
    }
  }
}

# Database Outputs (conditional based on deployed environments)
output "database_outputs" {
  description = "Outputs for all deployed database environments"
  value = {
    for env in var.database_environments : env => {
      public_ip   = aws_eip.database_eip[env].public_ip
      instance_id = aws_instance.database[env].id
      domain      = "db-${env}.${var.db_domain}"
    }
  }
}

# Individual database outputs for backward compatibility
output "database_dev_ip" {
  description = "Public IP of the development database"
  value       = contains(var.database_environments, "development") ? aws_eip.database_eip["development"].public_ip : "Development database not deployed"
}

output "database_homolog_ip" {
  description = "Public IP of the Homolog database"
  value       = contains(var.database_environments, "homolog") ? aws_eip.database_eip["homolog"].public_ip : "Homolog database not deployed"
}

output "database_dev_instance_id" {
  description = "Instance ID of the development database"
  value       = contains(var.database_environments, "development") ? aws_instance.database["development"].id : "Development database not deployed"
}

output "database_homolog_instance_id" {
  description = "Instance ID of the homolog database"
  value       = contains(var.database_environments, "homolog") ? aws_instance.database["homolog"].id : "Homolog database not deployed"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.ipecode_vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}