#########
## SES ##
#########
output "domain_verification_record" {
  value = {
    name  = "_amazonses.${var.domain}"
    type  = "TXT"
    value = aws_ses_domain_identity.this.verification_token
  }
}

output "dkim_records" {
  value = var.enable_dkim ? [
    for token in aws_ses_domain_dkim.this[0].dkim_tokens : {
      name  = "${token}._domainkey.${var.domain}"
      type  = "CNAME"
      value = "${token}.dkim.amazonses.com"
    }
  ] : []
}