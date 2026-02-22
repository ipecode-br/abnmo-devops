# ABNMO-SVM Two-phase deployment guide

This deployment requires two phases due to DNS validation requirements for SSL certificates.

## Phase 1: Get DNS validation records

**Goal**: Create ACM certificate and get DNS validation records to add to your domain.

### Step 1: Run Terraform (Phase 1)
```bash
export AWS_PROFILE=your-profile
terraform plan -out=tfplan
terraform apply tfplan
```

The certificate will be created, but lambdas and custom domains will be skipped.

### Step 2: Get DNS records
```bash
terraform output dns_validation_records_formatted
```

You'll see output like:
```
dns_validation_records_formatted = {
  "*.svm.abnmo.org" = {
    "domain" = "*.svm.abnmo.org"
    "name"   = "_1234abcd5678efgh.svm.abnmo.org."
    "type"   = "CNAME"
    "value"  = "_xyz789abc123.ltfvzjuylp.acm-validations.aws."
  }
  "svm.abnmo.org" = {
    "domain" = "svm.abnmo.org"
    "name"   = "_9876fedc5432ba10.svm.abnmo.org."
    "type"   = "CNAME" 
    "value"  = "_def456ghi789.ltfvzjuylp.acm-validations.aws."
  }
}
```

**Important**: You'll typically see 2 records - one for the wildcard (`*.domain`) and one for the root domain.

### Step 3: Add DNS records to your domain
For each record in the output, add a CNAME record to your DNS provider:

**Example for record `_1234abcd5678efgh.svm.abnmo.org.`:**
- **Name**: `_1234abcd5678efgh` (remove `.svm.abnmo.org.` from the name)
- **Type**: `CNAME`
- **Value**: `_xyz789abc123.ltfvzjuylp.acm-validations.aws.` (use exact value shown)
- **TTL**: `300` or `3600` (5 minutes or 1 hour)

**Important notes:**
- The trailing dot in names/values is optional depending on your DNS provider
- Some providers automatically append your domain to the name field
- Record names will be long random strings starting with underscore `_`

### Step 4: Wait for DNS propagation
Wait 5-15 minutes, then verify DNS records are active:

```bash
# Check if the DNS record exists (replace with your actual record name)
dig _abc123.svm.abnmo.org CNAME

# Alternative verification
nslookup _abc123.svm.abnmo.org
```

**Troubleshooting DNS issues:**
- Records can take up to 48 hours to propagate globally
- Use online DNS checkers like `whatsmydns.net` to verify from different locations
- Ensure you removed your domain from the record name when adding to DNS
- Contact your DNS provider if records aren't showing after 24 hours

## Phase 2: Deploy everything

**Goal**: Enable certificate validation and deploy all resources (lambdas, custom domains, etc.)

### Step 1: Enable phase 2

**Method 1: Update variables.tf (permanent change)**
```hcl
variable "dns_validation_complete" {
  type        = bool
  description = "Set to true after you've added the DNS validation records to your domain. Phase 1: false (get DNS records), Phase 2: true (deploy everything)"
  default     = true  # Change from false to true
}
```

**Method 2: Command line override (temporary)**
```bash
terraform plan -var="dns_validation_complete=true" -out=tfplan
terraform apply tfplan
```

**Note**: The current default is `true`, so if you're doing Phase 1, you need to set it to `false` first.

### Step 2: Deploy everything
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

This will:
- Validate the certificate
- Create custom domains
- Deploy all lambdas and API gateways
- Set up all configurations

## Summary

- **Phase 1**: `dns_validation_complete = false`  → Get DNS records
- **Phase 2**: `dns_validation_complete = true`   → Deploy everything

The variable controls both certificate validation AND custom domain creation in a single switch.

## Troubleshooting

### Common Issues

**Certificate validation stuck "Pending":**
- DNS records not added correctly
- DNS propagation not complete (wait 24-48 hours)
- Record name includes domain when it shouldn't

**"DNS validation failed" error:**
```bash
# Check current validation status
terraform output dns_validation_records_formatted

# Verify DNS records are active
dig _validation-record.svm.abnmo.org CNAME
```

**Phase 2 deployment fails:**
- Ensure certificate shows "ISSUED" status in AWS Certificate Manager
- Verify `dns_validation_complete = true` is set
- Re-run terraform apply after certificate validation completes

**Lambda deployment issues:**
- Check IAM permissions for deployment
- Verify S3 backend state file access
- Ensure all required secrets are in `secrets.auto.tfvars`

### Helpful Commands

```bash
# Check certificate status in AWS
aws acm list-certificates --region us-east-1

# View detailed certificate info
aws acm describe-certificate --certificate-arn <cert-arn>

# Test DNS resolution
dig api.svm.abnmo.org
nslookup api-dev.svm.abnmo.org
```
