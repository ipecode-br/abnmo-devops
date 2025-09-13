# Two-phase deployment guide

This deployment requires two phases due to DNS validation requirements.

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
  "*.abnmo.ipecode.com.br" = {
    "domain" = "*.abnmo.ipecode.com.br"
    "name"   = "_abc123.abnmo.ipecode.com.br."
    "type"   = "CNAME"
    "value"  = "_xyz789.xlfgrmvvlj.acm-validations.aws."
  }
  "api.abnmo.ipecode.com.br" = {
    "domain" = "api.abnmo.ipecode.com.br"
    "name"   = "_def456.api.abnmo.ipecode.com.br."
    "type"   = "CNAME" 
    "value"  = "_uvw012.xlfgrmvvlj.acm-validations.aws."
  }
  # ... more records
}
```

### Step 3: Add DNS records to your domain
For each record in the output, add a CNAME record to your DNS provider:

- **Name**: Remove your domain from the name (e.g., `abc123` instead of `abc123.abnmo.ipecode.com.br`)
- **Type**: CNAME
- **Value**: Use the exact value shown

### Step 4: Wait for DNS propagation
Wait 5-15 minutes, then verify:
```bash
dig abc123.abnmo.ipecode.com.br CNAME
```

## Phase 2: Deploy everything

**Goal**: Enable certificate validation and deploy all resources (lambdas, custom domains, etc.)

### Step 1: Enable phase 2
Change the variable in `variables.tf`:
```hcl
variable "dns_validation_complete" {
  type        = bool
  description = "Set to true after you've added the DNS validation records to your domain. Phase 1: false (get DNS records), Phase 2: true (deploy everything)"
  default     = true  # Change from false to true
}
```

**OR** use command line:
```bash
terraform plan -var="dns_validation_complete=true" -out=tfplan
terraform apply tfplan
```

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
