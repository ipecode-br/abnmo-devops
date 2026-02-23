terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
  }

  backend "s3" {
    bucket  = "svm-abnmo-iac-bucket"
    key     = "state/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  backend_configs = {
    development = {
      cors_allow_origins = ["https://staging.${var.app_domain}"]
      environment_variables = {
        NODE_ENV                  = "development"
        APP_ENVIRONMENT           = "lambda"
        MAINTENANCE               = "false"
        APP_URL                   = "https://staging.${var.app_domain}"
        COOKIE_DOMAIN             = var.app_domain
        COOKIE_SECRET             = var.dev_cookie_secret
        JWT_SECRET                = var.dev_jwt_secret
        ENABLE_EMAILS             = "false"
        DB_HOST                   = "db-development.${var.db_domain}"
        DB_PORT                   = "3306"
        DB_DATABASE               = "abnmo_dev"
        DB_USERNAME               = "abnmo_dev"
        DB_PASSWORD               = var.dev_db_password
        AWS_SES_REGION            = var.aws_region
        AWS_SES_ACCESS_KEY_ID     = var.aws_ses_access_key_id
        AWS_SES_SECRET_ACCESS_KEY = var.aws_ses_secret_access_key
        AWS_SES_FROM_EMAIL        = "tecnologia@abnmo.org"
      }
    }
    homolog = {
      cors_allow_origins = ["https://homolog.${var.app_domain}"]
      environment_variables = {
        NODE_ENV                  = "homolog"
        APP_ENVIRONMENT           = "lambda"
        MAINTENANCE               = "false"
        APP_URL                   = "https://homolog.${var.app_domain}"
        COOKIE_DOMAIN             = var.app_domain
        COOKIE_SECRET             = var.homolog_cookie_secret
        JWT_SECRET                = var.homolog_jwt_secret
        ENABLE_EMAILS             = "false"
        DB_HOST                   = "db-homolog.${var.db_domain}"
        DB_PORT                   = "3306"
        DB_DATABASE               = "abnmo_homolog"
        DB_USERNAME               = "abnmo_homolog"
        DB_PASSWORD               = var.homolog_db_password
        AWS_SES_REGION            = var.aws_region
        AWS_SES_ACCESS_KEY_ID     = var.aws_ses_access_key_id
        AWS_SES_SECRET_ACCESS_KEY = var.aws_ses_secret_access_key
        AWS_SES_FROM_EMAIL        = "tecnologia@abnmo.org"
      }
    }
    production = {
      cors_allow_origins = ["https://${var.app_domain}"]
      environment_variables = {
        NODE_ENV                  = "production"
        APP_ENVIRONMENT           = "lambda"
        MAINTENANCE               = "false"
        APP_URL                   = "https://${var.app_domain}"
        COOKIE_DOMAIN             = var.app_domain
        COOKIE_SECRET             = var.prod_cookie_secret
        JWT_SECRET                = var.prod_jwt_secret
        ENABLE_EMAILS             = "false"
        DB_HOST                   = "db-production.${var.db_domain}"
        DB_PORT                   = "3306"
        DB_DATABASE               = var.prod_db_name
        DB_USERNAME               = var.prod_db_user
        DB_PASSWORD               = var.prod_db_password
        AWS_SES_REGION            = var.aws_region
        AWS_SES_ACCESS_KEY_ID     = var.aws_ses_access_key_id
        AWS_SES_SECRET_ACCESS_KEY = var.aws_ses_secret_access_key
        AWS_SES_FROM_EMAIL        = "tecnologia@abnmo.org"
      }
    }
  }

  domain_mappings = {
    development = "api-dev.${var.app_domain}"
    homolog     = "api-homolog.${var.app_domain}"
    production  = "api.${var.app_domain}"
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

  # novas variáveis de budget
  budget_limit  = var.budget_limit
  budget_emails = var.budget_emails
}

module "ses_abnmo" {
  source = "./modules/ses"

  domain     = "abnmo.org"
  manage_dns = false

  email_identities = [
    "svm@abnmo.org"
  ]
}
