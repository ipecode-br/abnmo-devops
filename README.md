# ABNMO Infrastructure

This Terraform configuration creates the infrastructure for the ABNMO project on AWS, including:

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
# Deploy all environments
backend_environments  = ["development", "homolog", "production"]
database_environments = ["development", "homolog", "production"]

# Deploy only development and homolog
backend_environments  = ["development", "homolog"]
database_environments = ["development", "homolog"]

# Deploy only production backend with no databases
backend_environments  = ["production"]
database_environments = []

# Deploy everything except production database (for security)
backend_environments  = ["development", "homolog", "production"]
database_environments = ["development", "homolog"]
```

This allows you to:
- Start with just development environment
- Add staging/homolog when needed
- Deploy production separately for security
- Skip database deployment if using external database services

## SSL certificate management

This setup uses a **single wildcard certificate** (`*.abnmo.ipecode.com.br`) that covers all API subdomains. This approach:

✅ **Eliminates slow deployments** - No need to create/validate certificates for each environment  
✅ **Simplifies DNS management** - Only one DNS validation record needed  
✅ **Reduces costs** - Single certificate instead of multiple  
✅ **Easier domain changes** - Update domain in one place (`api_domain` variable)

### Current certificate coverage

The wildcard certificate covers:
- `api.abnmo.ipecode.com.br` (production)
- `api-dev.abnmo.ipecode.com.br` (development)
- `api-homolog.abnmo.ipecode.com.br` (homolog)
- Any future `*.abnmo.ipecode.com.br` subdomain

### Changing the API domain

To use a different domain, simply update the `api_domain` variable in `variables.tf`:

```hcl
variable "api_domain" {
  type        = string
  description = "Base domain for API endpoints"
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
- Password: located in `secrets.auto.tfvars` file
- Host: available via `terraform output database_dev_ip`

**Homolog environment:**
- Database: `abnmo_homolog`
- User: `abnmo_homolog` 
- Password: located in `secrets.auto.tfvars` file
- Host: available via `terraform output database_homolog_ip`

### Connecting to MySQL from Lambda

The Lambda functions are configured to connect to the databases using the Elastic IP addresses.

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

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan the deployment:
   ```bash
   terraform plan -out=tfplan
   ```

5. Apply the configuration:
   ```bash
   terraform apply tfplan
   ```

### Deployment strategies

**Gradual deployment:**
1. Start with development only: `backend_environments = ["development"]`
2. Add homolog when ready: `backend_environments = ["development", "homolog"]`
3. Add production: `backend_environments = ["development", "homolog", "production"]`

**Security-first deployment:**
- Deploy production backend but manage database separately
- Use `database_environments = ["development", "homolog"]` to exclude production database

## Security

- No SSH keys required - access via SSM Session Manager
- IAM roles follow principle of least privilege

## Environments

- **Development**: Uses EC2 MySQL database, accessible via custom domain
- **Homolog**: Uses EC2 MySQL database, accessible via custom domain  
- **Production**: Uses EC2 MySQL database, accessible via custom domain
