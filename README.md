# ABNMO-SVM Infrastructure

This Terraform configuration creates the infrastructure for the ABNMO-SVM project on AWS, including:

- Lambda functions for backend API (conditional per environment)
- EC2 instances with MySQL databases (conditional per environment)
- VPC with public subnets
- Security groups
- IAM roles for SSM access
- Centralized wildcard SSL certificate for all API subdomains

## Environment management

This infrastructure supports **conditional deployment** of environments. You can control which environments are deployed using variables:

### Environment variables

- `backend_environments`: Controls which backend environments (Lambda + API Gateway) to deploy
- `database_environments`: Controls which database environments to deploy

### Example configurations

```hcl
# Deploy all environments (production requires manual configuration)
backend_environments  = ["development", "homolog", "production"]
database_environments = ["development", "homolog", "production"]

# Default configuration - development and homolog only
backend_environments  = ["development", "homolog"]
database_environments = ["development", "homolog"]

# Deploy only development
backend_environments  = ["development"]
database_environments = ["development"]

# Deploy production backend with existing databases (recommended for security)
backend_environments  = ["development", "homolog", "production"]
database_environments = ["development", "homolog"]
```

This allows you to:
- Start with just development environment
- Add staging/homolog when needed
- Deploy production separately for security
- Skip database deployment if using external database services

## SSL certificate management

This setup uses a **single wildcard certificate** (`*.svm.abnmo.org`) that covers all API subdomains. This approach:

✅ **Eliminates slow deployments** - No need to create/validate certificates for each environment  
✅ **Simplifies DNS management** - Only one DNS validation record needed  
✅ **Reduces costs** - Single certificate instead of multiple  
✅ **Easier domain changes** - Update domain in one place (`app_domain` variable)

### Current certificate coverage

The wildcard certificate covers:
- `api.svm.abnmo.org` (production)
- `api-dev.svm.abnmo.org` (development)
- `api-homolog.svm.abnmo.org` (homolog)
- Any future `*.svm.abnmo.org` subdomain

### Changing the API domain

To use a different domain, update the `app_domain` and `db_domain` variables in `variables.tf`:

```hcl
variable "app_domain" {
  type        = string
  description = "Base domain for API endpoints"
  default     = "your-new-domain.com"  # Change this
}

variable "db_domain" {
  type        = string  
  description = "Base domain for database endpoints"
  default     = "your-new-domain.com"  # Change this
}
```

The certificate will automatically use the new domain for all environments.

## Database access

The EC2 database instances are configured to use AWS Systems Manager (SSM) Session Manager for secure access without SSH keys.

### MySQL database details

**Development environment:**
- Database: `abnmo_dev`
- User: `abnmo_dev`
- Password: `dev_db_password` in `secrets.auto.tfvars` file
- Host: available via `terraform output database_dev_ip` (when database is deployed)

**Homolog environment:**
- Database: `abnmo_homolog`
- User: `abnmo_homolog` 
- Password: `homolog_db_password` in `secrets.auto.tfvars` file
- Host: available via `terraform output database_homolog_ip` (when database is deployed)

**Production environment:**
- Database: `prod_db_name` in `secrets.auto.tfvars` file
- User: `prod_db_user` in `secrets.auto.tfvars` file
- Password: `prod_db_password` in `secrets.auto.tfvars` file
- Host: available via `terraform output` (when database is deployed)

### Additional secrets

The Lambda functions also require these secrets (all defined in `secrets.auto.tfvars`):

- **Cookie secrets**: `dev_cookie_secret`, `homolog_cookie_secret`, `prod_cookie_secret`
- **JWT secrets**: `dev_jwt_secret`, `homolog_jwt_secret`, `prod_jwt_secret`  
- **MySQL root password**: `mysql_root_password`

### Connecting to MySQL from Lambda

The Lambda functions are configured to connect to the databases using the Elastic IP addresses.

## Two-phase deployment

This infrastructure uses a **two-phase deployment process** due to DNS certificate validation requirements:

1. **Phase 1**: Deploy certificate and get DNS validation records
2. **Phase 2**: Add DNS records to your domain, then deploy everything

The `dns_validation_complete` variable controls this process:
- `false`: Phase 1 - Creates certificate, shows DNS records needed
- `true`: Phase 2 - Deploys Lambda functions and custom domains

**See detailed step-by-step instructions in [`docs/dns-certificates.md`](docs/dns-certificates.md)**

## Deployment

1. Set AWS profile:
   ```bash
   export AWS_PROFILE=your-profile
   ```

2. Copy the example secrets file and customize:
   ```bash
   cp secrets.auto.tfvars.example secrets.auto.tfvars
   # Edit secrets.auto.tfvars to set the secrets
   ```

3. Initialize Terraform (uses S3 backend for state):
   ```bash
   terraform init
   ```

   **Note**: The Terraform state is stored in S3 bucket `abnmo-svm-iac-bucket` for shared access and backup.

4. Plan the deployment:
   ```bash
   terraform plan -out=tfplan
   ```

5. Apply the configuration:
   ```bash
   terraform apply tfplan
   ```

### Deployment strategies

**Default configuration (recommended):**
- Deploy development and homolog: `backend_environments = ["development", "homolog"]`
- Both environments use dedicated EC2 MySQL databases

**Production deployment:**
1. First deploy development and homolog to test
2. Add production: `backend_environments = ["development", "homolog", "production"]`  
3. For security, consider external database for production: `database_environments = ["development", "homolog"]`

**Phase-by-phase deployment:**
1. **Phase 1**: Set `dns_validation_complete = false`, run `terraform apply`
2. **Phase 2**: Add DNS records, set `dns_validation_complete = true`, run `terraform apply` again

## Security

- No SSH keys required - access via SSM Session Manager
- IAM roles follow principle of least privilege

## Environments

- **Development**: Uses EC2 MySQL database, accessible via custom domain
- **Homolog**: Uses EC2 MySQL database, accessible via custom domain  
- **Production**: Uses EC2 MySQL database, accessible via custom domain
