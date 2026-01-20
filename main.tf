terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }

  backend "s3" {
    bucket  = "abnmo-svm-iac-bucket"
    key     = "state/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  backend_configs = {
    development = {
      cors_allow_origins = ["https://staging.abnmo.ipecode.com.br"]
      environment_variables = {
        NODE_ENV           = "development"
        APP_ENVIRONMENT    = "development"
        APP_URL            = "https://staging.abnmo.ipecode.com.br"
        COOKIE_DOMAIN      = var.api_domain
        COOKIE_SECRET      = var.dev_cookie_secret
        JWT_SECRET         = var.dev_jwt_secret
        DB_HOST            = "db-development.${var.db_domain}"
        DB_PORT            = "3306"
        DB_DATABASE        = "abnmo_dev"
        DB_USERNAME        = "abnmo_dev"
        DB_PASSWORD        = var.dev_db_password
        AWS_SES_FROM_EMAIL = "email@domain.com"
      }
    }
    homolog = {
      cors_allow_origins = ["https://homolog.abnmo.ipecode.com.br"]
      environment_variables = {
        NODE_ENV           = "homolog"
        APP_ENVIRONMENT    = "homolog"
        APP_URL            = "https://homolog.abnmo.ipecode.com.br"
        COOKIE_DOMAIN      = var.api_domain
        COOKIE_SECRET      = var.homolog_cookie_secret
        JWT_SECRET         = var.homolog_jwt_secret
        DB_HOST            = "db-homolog.${var.db_domain}"
        DB_PORT            = "3306"
        DB_DATABASE        = "abnmo_homolog"
        DB_USERNAME        = "abnmo_homolog"
        DB_PASSWORD        = var.homolog_db_password
        AWS_SES_FROM_EMAIL = "email@domain.com"
      }
    }
    production = {
      cors_allow_origins = ["https://abnmo.ipecode.com.br"]
      environment_variables = {
        NODE_ENV           = "production"
        APP_ENVIRONMENT    = "production"
        APP_URL            = "https://abnmo.ipecode.com.br"
        COOKIE_DOMAIN      = var.api_domain
        COOKIE_SECRET      = var.prod_cookie_secret
        JWT_SECRET         = var.prod_jwt_secret
        DB_HOST            = "db-prod.${var.db_domain}"
        DB_PORT            = "3306"
        DB_DATABASE        = var.prod_db_name
        DB_USERNAME        = var.prod_db_user
        DB_PASSWORD        = var.prod_db_password
        AWS_SES_FROM_EMAIL = "email@domain.com"
      }
    }
  }

  domain_mappings = {
    development = "api-dev.${var.api_domain}"
    homolog     = "api-homolog.${var.api_domain}"
    production  = "api.${var.api_domain}"
  }
}

module "abnmo_svm_backend" {
  for_each = var.backend_environments

  source      = "./modules/backend"
  environment = each.key

  custom_domain_name       = var.dns_validation_complete ? local.domain_mappings[each.key] : null
  certificate_arn          = aws_acm_certificate.wildcard_api.arn
  github_oidc_provider_arn = aws_iam_openid_connect_provider.github.arn
  cors_allow_origins       = local.backend_configs[each.key].cors_allow_origins
  environment_variables    = local.backend_configs[each.key].environment_variables
}